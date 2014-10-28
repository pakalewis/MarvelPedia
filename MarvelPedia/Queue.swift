//
//  Queue.swift
//  MarvelPedia
//
//  Created by Alex G on 28.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation

class QueueItem<T> {
    var item: T?
    var next: QueueItem<T>?
    var prev: QueueItem<T>?
    
    init(_ item: T) {
        self.item = item
    }
}

class Queue<T> {
    
    private var head: QueueItem<T>?
    private var tail: QueueItem<T>?
    var size: Int = 0
    
    func enqueue(object: T) {
        size++
        let newItem = QueueItem<T>(object)
        if head == nil {
            head = newItem
            tail = head
            return
        }
        
        newItem.next = head
        head?.prev = newItem
        head = newItem
    }
    
    func dequeue() -> T? {
        if tail == nil {
            return nil
        }
        
        let lastItem: QueueItem<T>! = tail
        tail = tail?.prev
        if tail == nil {
            head = nil
        } else {
            tail?.next = nil
        }
    
        lastItem.prev = nil
        size--
        return lastItem.item
    }
    
    func traverse() {
        println("Traversing queue")
        var item = head
        while item != nil {
            println(item?.item)
            item = item?.next
        }
    }
    
    init() {
    }
}