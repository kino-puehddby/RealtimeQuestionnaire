//
//  DatabaseCollection.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/22.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase

public protocol DatabaseCollection {
    associatedtype FieldType: Codable
    static var collectionKey: CollectionKey { get }
    var id: String { get }
    var fields: FieldType? { get }
    init(id: String, fields: FieldType?)
    init(fields: FieldType)
    static func makeCollectionRef() -> CollectionReference
    static func makeDocumentRef(id: String) -> DocumentReference
    func makeDocumentRef() -> DocumentReference
}

extension DatabaseCollection {
    public init(id: String) {
        self.init(id: id, fields: nil)
    }
    public static func makeCollectionRef() -> CollectionReference {
        return Firestore.firestore().collection(collectionKey.rawValue)
    }
    public static func makeDocumentRef(id: String) -> DocumentReference {
        return Self.makeCollectionRef().document(id)
    }
    public func makeDocumentRef() -> DocumentReference {
        return Self.makeDocumentRef(id: id)
    }
}
