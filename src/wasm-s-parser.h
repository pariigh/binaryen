/*
 * Copyright 2015 WebAssembly Community Group participants
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
// Parses WebAssembly code in S-Expression format, as in .wast files
// such as are in the spec test suite.
//

#ifndef wasm_wasm_s_parser_h
#define wasm_wasm_s_parser_h

#include "mixed_arena.h"
#include "parsing.h" // for UniqueNameMapper. TODO: move dependency to cpp file?
#include "wasm-builder.h"
#include "wasm.h"

namespace wasm {

class SourceLocation {
public:
  IString filename;
  uint32_t line;
  uint32_t column;
  SourceLocation(IString filename_, uint32_t line_, uint32_t column_ = 0)
    : filename(filename_), line(line_), column(column_) {}
};

//
// An element in an S-Expression: a list or a string
//
class Element {
  using List = ArenaVector<Element*>;

  bool isList_ = true;
  List list_;
  IString str_;
  bool dollared_;
  bool quoted_;

public:
  Element(MixedArena& allocator) : list_(allocator) {}

  bool isList() const { return isList_; }
  bool isStr() const { return !isList_; }
  bool dollared() const { return isStr() && dollared_; }
  bool quoted() const { return isStr() && quoted_; }

  size_t line = -1;
  size_t col = -1;
  // original locations at the start/end of the S-Expression list
  SourceLocation* startLoc = nullptr;
  SourceLocation* endLoc = nullptr;

  // list methods
  List& list();
  Element* operator[](unsigned i);
  size_t size() { return list().size(); }
  List::Iterator begin() { return list().begin(); }
  List::Iterator end() { return list().end(); }

  // string methods
  IString str() const;
  // convert a string to a string
  std::string toString() const;
  // convert anything to a string
  std::string forceString() const;
  Element* setString(IString str__, bool dollared__, bool quoted__);
  Element* setMetadata(size_t line_, size_t col_, SourceLocation* startLoc_);

  // comparisons
  bool operator==(Name name) { return isStr() && str() == name; }

  template<typename T> bool operator!=(T t) { return !(*this == t); }

  // printing
  friend std::ostream& operator<<(std::ostream& o, const Element& e);
  void dump();
};

//
// Generic S-Expression parsing into lists
//
class SExpressionParser {
  const char* input;
  size_t line;
  char const* lineStart;
  SourceLocation* loc = nullptr;

  MixedArena allocator;

public:
  // Assumes control of and modifies the input.
  SExpressionParser(const char* input);
  Element* root;

private:
  Element* parse();
  void skipWhitespace();
  void parseDebugLocation();
  Element* parseString();
};

//
// SExpressions => WebAssembly module
//
class SExpressionWasmBuilder {
  Module& wasm;
  MixedArena& allocator;
  IRProfile profile;

  // The main list of types declared in the module
  std::vector<HeapType> types;
  std::unordered_map<std::string, size_t> typeIndices;

  std::vector<Name> functionNames;
  std::vector<Name> tableNames;
  std::vector<Name> elemSegmentNames;
  std::vector<Name> memoryNames;
  std::vector<Name> dataSegmentNames;
  std::vector<Name> globalNames;
  std::vector<Name> tagNames;
  int functionCounter = 0;
  int globalCounter = 0;
  int tagCounter = 0;
  int tableCounter = 0;
  int elemCounter = 0;
  int memoryCounter = 0;
  int dataCounter = 0;
  // we need to know function return types before we parse their contents
  std::map<Name, HeapType> functionTypes;
  std::unordered_map<IString, Index> debugInfoFileIndices;

  // Maps type indexes to a mapping of field index => name. This is not the same
  // as the field names stored on the wasm object, as that maps types after
  // their canonicalization. Canonicalization loses information, which means
  // that structurally identical types cannot have different names. However,
  // while parsing the text format we keep this mapping of type indexes to names
  // which does allow reading such content.
  std::unordered_map<size_t, std::unordered_map<Index, Name>> fieldNames;

public:
  // Assumes control of and modifies the input.
  SExpressionWasmBuilder(Module& wasm, Element& module, IRProfile profile);

private:
  void preParseHeapTypes(Element& module);
  // pre-parse types and function definitions, so we know function return types
  // before parsing their contents
  void preParseFunctionType(Element& s);
  bool isImport(Element& curr);
  void preParseImports(Element& curr);
  void preParseMemory(Element& curr);
  void parseModuleElement(Element& curr);

  // function parsing state
  std::unique_ptr<Function> currFunction;
  bool brokeToAutoBlock;

  UniqueNameMapper nameMapper;

  int parseIndex(Element& s);

  Name getFunctionName(Element& s);
  Name getTableName(Element& s);
  Name getElemSegmentName(Element& s);
  Name getMemoryName(Element& s);
  Name getDataSegmentName(Element& s);
  Name getGlobalName(Element& s);
  Name getTagName(Element& s);
  void parseStart(Element& s) { wasm.addStart(getFunctionName(*s[1])); }

  Name getMemoryNameAtIdx(Index i);
  bool isMemory64(Name memoryName);
  bool hasMemoryIdx(Element& s, Index defaultSize, Index i);

  // returns the next index in s
  size_t parseFunctionNames(Element& s, Name& name, Name& exportName);
  void parseFunction(Element& s, bool preParseImport = false);

  Type stringToType(IString str, bool allowError = false, bool prefix = false) {
    return stringToType(str.str, allowError, prefix);
  }
  Type stringToType(std::string_view str,
                    bool allowError = false,
                    bool prefix = false);
  HeapType stringToHeapType(IString str, bool prefix = false) {
    return stringToHeapType(str.str, prefix);
  }
  HeapType stringToHeapType(std::string_view str, bool prefix = false);
  Type elementToType(Element& s);
  // TODO: Use std::string_view for this and similar functions.
  Type stringToLaneType(const char* str);
  bool isType(IString str) { return stringToType(str, true) != Type::none; }
  HeapType getFunctionType(Name name, Element& s);

public:
  Expression* parseExpression(Element* s) { return parseExpression(*s); }
  Expression* parseExpression(Element& s);

  Module& getModule() { return wasm; }

private:
  Expression* makeExpression(Element& s);
  Expression* makeUnreachable();
  Expression* makeNop();
  Expression* makeBinary(Element& s, BinaryOp op);
  Expression* makeUnary(Element& s, UnaryOp op);
  Expression* makeSelect(Element& s);
  Expression* makeDrop(Element& s);
  Expression* makeMemorySize(Element& s);
  Expression* makeMemoryGrow(Element& s);
  Index getLocalIndex(Element& s);
  Expression* makeLocalGet(Element& s);
  Expression* makeLocalTee(Element& s);
  Expression* makeLocalSet(Element& s);
  Expression* makeGlobalGet(Element& s);
  Expression* makeGlobalSet(Element& s);
  Expression* makeBlock(Element& s);
  Expression* makeThenOrElse(Element& s);
  Expression* makeConst(Element& s, Type type);
  Expression*
  makeLoad(Element& s, Type type, bool signed_, int bytes, bool isAtomic);
  Expression* makeStore(Element& s, Type type, int bytes, bool isAtomic);
  Expression*
  makeAtomicRMW(Element& s, AtomicRMWOp op, Type type, uint8_t bytes);
  Expression* makeAtomicCmpxchg(Element& s, Type type, uint8_t bytes);
  Expression* makeAtomicWait(Element& s, Type type);
  Expression* makeAtomicNotify(Element& s);
  Expression* makeAtomicFence(Element& s);
  Expression* makeSIMDExtract(Element& s, SIMDExtractOp op, size_t lanes);
  Expression* makeSIMDReplace(Element& s, SIMDReplaceOp op, size_t lanes);
  Expression* makeSIMDShuffle(Element& s);
  Expression* makeSIMDTernary(Element& s, SIMDTernaryOp op);
  Expression* makeSIMDShift(Element& s, SIMDShiftOp op);
  Expression* makeSIMDLoad(Element& s, SIMDLoadOp op, int bytes);
  Expression*
  makeSIMDLoadStoreLane(Element& s, SIMDLoadStoreLaneOp op, int bytes);
  Expression* makeMemoryInit(Element& s);
  Expression* makeDataDrop(Element& s);
  Expression* makeMemoryCopy(Element& s);
  Expression* makeMemoryFill(Element& s);
  Expression* makePop(Element& s);
  Expression* makeIf(Element& s);
  Expression* makeMaybeBlock(Element& s, size_t i, Type type);
  Expression* makeLoop(Element& s);
  Expression* makeCall(Element& s, bool isReturn);
  Expression* makeCallIndirect(Element& s, bool isReturn);
  template<class T> void parseOperands(Element& s, Index i, Index j, T& list) {
    while (i < j) {
      list.push_back(parseExpression(s[i]));
      i++;
    }
  }
  template<class T>
  void parseCallOperands(Element& s, Index i, Index j, T* call) {
    parseOperands(s, i, j, call->operands);
  }
  enum class LabelType { Break, Exception };
  Name getLabel(Element& s, LabelType labelType = LabelType::Break);
  Expression* makeBreak(Element& s);
  Expression* makeBreakTable(Element& s);
  Expression* makeReturn(Element& s);
  Expression* makeRefNull(Element& s);
  Expression* makeRefIsNull(Element& s);
  Expression* makeRefFunc(Element& s);
  Expression* makeRefEq(Element& s);
  Expression* makeTableGet(Element& s);
  Expression* makeTableSet(Element& s);
  Expression* makeTableSize(Element& s);
  Expression* makeTableGrow(Element& s);
  Expression* makeTableFill(Element& s);
  Expression* makeTableCopy(Element& s);
  Expression* makeTry(Element& s);
  Expression* makeTryTable(Element& s);
  Expression* makeThrow(Element& s);
  Expression* makeRethrow(Element& s);
  Expression* makeThrowRef(Element& s);
  Expression* makeTupleMake(Element& s);
  Expression* makeTupleExtract(Element& s);
  Expression* makeTupleDrop(Element& s);
  Expression* makeCallRef(Element& s, bool isReturn);
  Expression* makeRefI31(Element& s);
  Expression* makeI31Get(Element& s, bool signed_);
  Expression* makeRefTest(Element& s);
  Expression* makeRefCast(Element& s);
  Expression* makeBrOnNull(Element& s, bool onFail = false);
  Expression* makeBrOnCast(Element& s, bool onFail = false);
  Expression* makeStructNew(Element& s, bool default_);
  Index getStructIndex(Element& type, Element& field);
  Expression* makeStructGet(Element& s, bool signed_ = false);
  Expression* makeStructSet(Element& s);
  Expression* makeArrayNew(Element& s, bool default_);
  Expression* makeArrayNewData(Element& s);
  Expression* makeArrayNewElem(Element& s);
  Expression* makeArrayNewFixed(Element& s);
  Expression* makeArrayGet(Element& s, bool signed_ = false);
  Expression* makeArraySet(Element& s);
  Expression* makeArrayLen(Element& s);
  Expression* makeArrayCopy(Element& s);
  Expression* makeArrayFill(Element& s);
  Expression* makeArrayInitData(Element& s);
  Expression* makeArrayInitElem(Element& s);
  Expression* makeRefAs(Element& s, RefAsOp op);
  Expression* makeRefAsNonNull(Element& s);
  Expression* makeStringNew(Element& s, StringNewOp op, bool try_);
  Expression* makeStringConst(Element& s);
  Expression* makeStringMeasure(Element& s, StringMeasureOp op);
  Expression* makeStringEncode(Element& s, StringEncodeOp op);
  Expression* makeStringConcat(Element& s);
  Expression* makeStringEq(Element& s, StringEqOp op);
  Expression* makeStringAs(Element& s, StringAsOp op);
  Expression* makeStringWTF8Advance(Element& s);
  Expression* makeStringWTF16Get(Element& s);
  Expression* makeStringIterNext(Element& s);
  Expression* makeStringIterMove(Element& s, StringIterMoveOp op);
  Expression* makeStringSliceWTF(Element& s, StringSliceWTFOp op);
  Expression* makeStringSliceIter(Element& s);

  // Helper functions
  Type parseBlockType(Element& s, Index& i);
  Index parseMemoryLimits(Element& s, Index i, std::unique_ptr<Memory>& memory);
  Index parseMemoryIndex(Element& s, Index i, std::unique_ptr<Memory>& memory);
  Index parseMemoryForInstruction(const std::string& instrName,
                                  Memory& memory,
                                  Element& s,
                                  Index i);
  std::vector<Type> parseParamOrLocal(Element& s);
  std::vector<NameType> parseParamOrLocal(Element& s, size_t& localIndex);
  std::vector<Type> parseResults(Element& s);
  HeapType parseTypeRef(Element& s);
  size_t parseTypeUse(Element& s,
                      size_t startPos,
                      HeapType& functionType,
                      std::vector<NameType>& namedParams);
  size_t parseTypeUse(Element& s, size_t startPos, HeapType& functionType);

  void
  stringToBinary(Element& s, std::string_view str, std::vector<char>& data);
  void parseMemory(Element& s, bool preParseImport = false);
  void parseData(Element& s);
  void parseInnerData(Element& s, Index i, std::unique_ptr<DataSegment>& seg);
  void parseExport(Element& s);
  void parseImport(Element& s);
  void parseGlobal(Element& s, bool preParseImport = false);
  void parseTable(Element& s, bool preParseImport = false);
  void parseElem(Element& s, Table* table = nullptr);
  ElementSegment* parseElemFinish(Element& s,
                                  std::unique_ptr<ElementSegment>& segment,
                                  Index i = 1,
                                  bool usesExpressions = false);

  // Parses something like (func ..), (array ..), (struct)
  HeapType parseHeapType(Element& s);

  void parseTag(Element& s, bool preParseImport = false);

  Function::DebugLocation getDebugLocation(const SourceLocation& loc);

  // Struct/Array instructions have an unnecessary heap type that is just for
  // validation (except for the case of unreachability, but that's not a problem
  // anyhow, we can ignore it there). That is, we also have a reference typed
  // child from which we can infer the type anyhow, and we just need to check
  // that type is the same.
  void
  validateHeapTypeUsingChild(Expression* child, HeapType heapType, Element& s);
};

} // namespace wasm

#endif // wasm_wasm_s_parser_h
