//
//  AppAppLinkedList.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/17/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

public final class AppLinkedList<T> {
    
    public class AppLinkedListNode<T> {
        var value: T
        var next: AppLinkedListNode?
        weak var previous: AppLinkedListNode?
        
        public init(value: T) {
            self.value = value
        }
    }
    
    public typealias AppNode = AppLinkedListNode<T>
    
    fileprivate var head: AppNode?
    
    public init() {}
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: AppNode? {
        return head
    }
    
    public var last: AppNode? {
        if var node = head {
            while case let next? = node.next {
                node = next
            }
            return node
        } else {
            return nil
        }
    }
    
    public var count: Int {
        if var node = head {
            var c = 1
            while case let next? = node.next {
                node = next
                c += 1
            }
            return c
        } else {
            return 0
        }
    }
    
    public func node(atIndex index: Int) -> AppNode? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }
    
    public subscript(index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return node!.value
    }
    
    public func append(_ value: T) {
        let newAppNode = AppNode(value: value)
        self.append(newAppNode)
    }
    
    public func append(_ node: AppNode) {
        let newAppNode = AppLinkedListNode(value: node.value)
        if let lastAppNode = last {
            newAppNode.previous = lastAppNode
            lastAppNode.next = newAppNode
        } else {
            head = newAppNode
        }
    }
    
    public func append(_ list: AppLinkedList) {
        var nodeToCopy = list.head
        while let node = nodeToCopy {
            self.append(node.value)
            nodeToCopy = node.next
        }
    }
    
    private func nodesBeforeAndAfter(index: Int) -> (AppNode?, AppNode?) {
        assert(index >= 0)
        
        var i = index
        var next = head
        var prev: AppNode?
        
        while next != nil && i > 0 {
            i -= 1
            prev = next
            next = next!.next
        }
        assert(i == 0)  // if > 0, then specified index was too large
        return (prev, next)
    }
    
    public func insert(_ value: T, atIndex index: Int) {
        let newAppNode = AppNode(value: value)
        self.insert(newAppNode, atIndex: index)
    }
    
    public func insert(_ node: AppNode, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index: index)
        let newAppNode = AppLinkedListNode(value: node.value)
        newAppNode.previous = prev
        newAppNode.next = next
        prev?.next = newAppNode
        next?.previous = newAppNode
        
        if prev == nil {
            head = newAppNode
        }
    }
    
    public func insert(_ list: AppLinkedList, atIndex index: Int) {
        if list.isEmpty { return }
        var (prev, next) = nodesBeforeAndAfter(index: index)
        var nodeToCopy = list.head
        var newAppNode: AppNode?
        while let node = nodeToCopy {
            newAppNode = AppNode(value: node.value)
            newAppNode?.previous = prev
            if let previous = prev {
                previous.next = newAppNode
            } else {
                self.head = newAppNode
            }
            nodeToCopy = nodeToCopy?.next
            prev = newAppNode
        }
        prev?.next = next
        next?.previous = prev
    }
    
    public func removeAll() {
        head = nil
    }
    
    @discardableResult public func remove(node: AppNode) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    
    @discardableResult public func removeLast() -> T {
        assert(!isEmpty)
        return remove(node: last!)
    }
    
    @discardableResult public func remove(atIndex index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return remove(node: node!)
    }
}

extension AppLinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = head
        while node != nil {
            s += "\(node!.value)"
            node = node!.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

extension AppLinkedList {
    public func reverse() {
        var node = head
        while let currentAppNode = node {
            node = currentAppNode.next
            swap(&currentAppNode.next, &currentAppNode.previous)
            head = currentAppNode
        }
    }
}

extension AppLinkedList {
    public func map<U>(transform: (T) -> U) -> AppLinkedList<U> {
        let result = AppLinkedList<U>()
        var node = head
        while node != nil {
            result.append(transform(node!.value))
            node = node!.next
        }
        return result
    }
    
    public func filter(predicate: (T) -> Bool) -> AppLinkedList<T> {
        let result = AppLinkedList<T>()
        var node = head
        while node != nil {
            if predicate(node!.value) {
                result.append(node!.value)
            }
            node = node!.next
        }
        return result
    }
}

extension AppLinkedList {
    convenience init(array: Array<T>) {
        self.init()
        
        for element in array {
            self.append(element)
        }
    }
}

extension AppLinkedList: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: T...) {
        self.init()
        
        for element in elements {
            self.append(element)
        }
    }
}
