//
//  SafeArray.swift
//  MyCode
//
//  Created by 影孤清 on 2019/3/25.
//  Copyright © 2019年 影孤清. All rights reserved.
//

import Foundation


/// 线程安全数组
struct SafeArray<T>: RangeReplaceableCollection {
    typealias Element = T
    typealias Index = Int
    typealias SubSequence = SafeArray<T>
    typealias Indices = Range<Int>
    fileprivate var array: Array<T>
    var startIndex: Int { return array.startIndex }
    var endIndex: Int { return array.endIndex }
    var indices: Range<Int> { return array.indices }
    
    func index(after i: Int) -> Int { return array.index(after: i) }
    
    private var semaphore = DispatchSemaphore(value: 1)
    fileprivate func _wait() { semaphore.wait() }
    fileprivate func _signal() { semaphore.signal() }
}

// Instance Methods
extension SafeArray {
    init<S>(_ elements: S) where S : Sequence, SafeArray.Element == S.Element {
        array = Array<S.Element>(elements)
    }
    
    init() { self.init([]) }
    
    init(repeating repeatedValue: SafeArray.Element, count: Int) {
        let array = Array(repeating: repeatedValue, count: count)
        self.init(array)
    }
    
    //init<S>(array:[S]) where S : Sequence, SafeArray.Element == S.Element {
        //Array<String>(
    //}
}

// Instance Methods
extension SafeArray {
    
    public mutating func append(_ newElement: SafeArray.Element) {
        _wait(); defer { _signal() }
        array.append(newElement)
    }
    
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, SafeArray.Element == S.Element {
        _wait(); defer { _signal() }
        array.append(contentsOf: newElements)
    }
    
    func filter(_ isIncluded: (SafeArray.Element) throws -> Bool) rethrows -> SafeArray {
        _wait(); defer { _signal() }
        let subArray = try array.filter(isIncluded)
        return SafeArray(subArray)
    }
    
    public mutating func insert(_ newElement: SafeArray.Element, at i: SafeArray.Index) {
        _wait(); defer { _signal() }
        array.insert(newElement, at: i)
    }
    
    mutating func insert<S>(contentsOf newElements: S, at i: SafeArray.Index) where S : Collection, SafeArray.Element == S.Element {
        _wait(); defer { _signal() }
        array.insert(contentsOf: newElements, at: i)
    }
    
    mutating func popLast() -> SafeArray.Element? {
        _wait(); defer { _signal() }
        return array.popLast()
    }
    
    @discardableResult mutating func remove(at i: SafeArray.Index) -> SafeArray.Element {
        _wait(); defer { _signal() }
        return array.remove(at: i)
    }
    
    mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        _wait(); defer { _signal() }
        array.removeAll()
    }
    
    mutating func removeAll(where shouldBeRemoved: (SafeArray.Element) throws -> Bool) rethrows {
        _wait(); defer { _signal() }
        try array.removeAll(where: shouldBeRemoved)
    }
    
    @discardableResult mutating func removeFirst() -> SafeArray.Element {
        _wait(); defer { _signal() }
        return array.removeFirst()
    }
    
    mutating func removeFirst(_ k: Int) {
        _wait(); defer { _signal() }
        array.removeFirst(k)
    }
    
    @discardableResult mutating func removeLast() -> SafeArray.Element {
        _wait(); defer { _signal() }
        return array.removeLast()
    }
    
    mutating func removeLast(_ k: Int) {
        _wait(); defer { _signal() }
        array.removeLast(k)
    }
    
    mutating func removeSubrange(_ bounds: Range<Int>) {
        _wait(); defer { _signal() }
        array.removeSubrange(bounds)
    }
    
    mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, T == C.Element, SafeArray<Element>.Index == R.Bound {
        _wait(); defer { _signal() }
        array.replaceSubrange(subrange, with: newElements)
    }
    
    mutating func reserveCapacity(_ n: Int) {
        _wait(); defer { _signal() }
        array.reserveCapacity(n)
    }
    
    public var count: Int {
        _wait(); defer { _signal() }
        return array.count
    }
    
    public var isEmpty: Bool {
        _wait(); defer { _signal() }
        return array.isEmpty
    }
}

// Get/Set
extension SafeArray {
    
    // Single  action
    
    func get() -> [T] {
        _wait(); defer { _signal() }
        return array
    }
    
    mutating func set(array: [T]) {
        _wait(); defer { _signal() }
        self.array = array
    }
    
    // Multy actions
    
    mutating func get(closure: ([T])->()) {
        _wait(); defer { _signal() }
        closure(array)
    }
    
    mutating func set(closure: ([T]) -> ([T])) {
        _wait(); defer { _signal() }
        array = closure(array)
    }
}

// Subscripts
extension SafeArray {
    
    subscript(bounds: Range<SafeArray.Index>) -> SafeArray.SubSequence {
        get {
            _wait(); defer { _signal() }
            return SafeArray(array[bounds])
        }
    }
    
    subscript(bounds: SafeArray.Index) -> SafeArray.Element {
        get {
            _wait(); defer { _signal() }
            return array[bounds]
        }
        set(value) {
            _wait(); defer { _signal() }
            array[bounds] = value
        }
    }
}

// Operator Functions
extension SafeArray {
    
    static func + <Other>(lhs: Other, rhs: SafeArray) -> SafeArray where Other : Sequence, SafeArray.Element == Other.Element {
        return SafeArray(lhs + rhs.get())
    }
    
    static func + <Other>(lhs: SafeArray, rhs: Other) -> SafeArray where Other : Sequence, SafeArray.Element == Other.Element {
        return SafeArray(lhs.get() + rhs)
    }
    
    static func + <Other>(lhs: SafeArray, rhs: Other) -> SafeArray where Other : RangeReplaceableCollection, SafeArray.Element == Other.Element {
        return SafeArray(lhs.get() + rhs)
    }
    
    static func + (lhs: SafeArray<Element>, rhs: SafeArray<Element>) -> SafeArray {
        return SafeArray(lhs.get() + rhs.get())
    }
    
    static func += <Other>(lhs: inout SafeArray, rhs: Other) where Other : Sequence, SafeArray.Element == Other.Element {
        lhs._wait(); defer { lhs._signal() }
        lhs.array += rhs
    }
}

extension SafeArray: CustomStringConvertible {
    var description: String {
        _wait(); defer { _signal() }
        return "\(array)"
    }
}

extension SafeArray where Element : Equatable {
    
    func split(separator: Element, maxSplits: Int, omittingEmptySubsequences: Bool) -> [ArraySlice<Element>] {
        _wait(); defer { _signal() }
        return array.split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
    }
    
    func firstIndex(of element: Element) -> Int? {
        _wait(); defer { _signal() }
        return array.firstIndex(of: element)
    }
    
    func lastIndex(of element: Element) -> Int? {
        _wait(); defer { _signal() }
        return array.lastIndex(of: element)
    }
    
    func starts<PossiblePrefix>(with possiblePrefix: PossiblePrefix) -> Bool where PossiblePrefix : Sequence, Element == PossiblePrefix.Element {
        _wait(); defer { _signal() }
        return array.starts(with: possiblePrefix)
    }
    
    func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        _wait(); defer { _signal() }
        return array.elementsEqual(other)
    }
    
    func contains(_ element: Element) -> Bool {
        _wait(); defer { _signal() }
        return array.contains(element)
    }
    
    static func != (lhs: SafeArray<Element>, rhs: SafeArray<Element>) -> Bool {
        lhs._wait(); defer { lhs._signal() }
        rhs._wait(); defer { rhs._signal() }
        return lhs.array != rhs.array
    }
    
    static func == (lhs: SafeArray<Element>, rhs: SafeArray<Element>) -> Bool {
        lhs._wait(); defer { lhs._signal() }
        rhs._wait(); defer { rhs._signal() }
        return lhs.array == rhs.array
    }
}


