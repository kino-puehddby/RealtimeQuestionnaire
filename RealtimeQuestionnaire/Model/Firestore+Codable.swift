//
//  Firestore+Codable.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import Firebase
import FirebaseFirestore
import CodableFirebase

enum CollectionKey: String {
    case questionnaireListGet = "QuestionnaireList"
}

class APIs {
    /**
     データの取得（配列）
     */
    static func getArray<T: Codable>(modelType: T.Type, collectionKey: CollectionKey) -> [T]? {
        let db = Firestore.firestore()
        var results: [T]?
        db.collection(collectionKey.rawValue).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            if let error = error {
                debugPrint("failed to get documents : \(error)")
            } else {
                results = makeResults(documents: documents, modelType: modelType)
            }
        }
        return results
    }
    
    /**
     データの取得
     */
    static func get<T: Codable>(modelType: T.Type, collectionKey: CollectionKey, documentPath: String) -> T? {
        let db = Firestore.firestore()
        var result: T?
        db.collection(collectionKey.rawValue).document(documentPath).getDocument { querySnapshot, error in
            guard let data = querySnapshot?.data() else { return }
            if let error = error {
                debugPrint("failed to get document : \(error)")
            } else {
               result = decode(modelType: modelType, data: data)
            }
        }
        debugPrint("result = \(String(describing: result))")
        return result
    }
    
    /**
     データの登録
     */
    static func setData<T: Codable>(model: T, collectionKey: CollectionKey, documentPath: String?) {
        let db = Firestore.firestore()
        guard let data = encode(model: model) else { return }
        if let documentPath = documentPath {
            db.collection(collectionKey.rawValue).document(documentPath).setData(data) { error in
                if let error = error {
                    debugPrint("error writing document: \(error)")
                } else {
                    debugPrint("Document added")
                }
            }
        } else {
            var ref: DocumentReference?
            ref = db.collection(collectionKey.rawValue).addDocument(data: data) { error in
                if let error = error {
                    debugPrint("error writing document: \(error)")
                } else {
                    debugPrint("Document added with ID: \(ref!.documentID)")
                }
            }
        }
    }
    
    /**
     データの更新
     */
    static func updateData<T: Codable>(newModel: T, collectionKey: CollectionKey, documentPath: String) {
        let db = Firestore.firestore()
        let targetRef = db.collection(collectionKey.rawValue).document(documentPath)
        guard let data = encode(model: newModel) else { return }
        targetRef.updateData(data) { error in
            if let error = error {
                debugPrint(error)
            } else {
                debugPrint("Document updated")
            }
        }
    }
    
    // - private function
    private static func makeResults<T: Codable>(documents: [QueryDocumentSnapshot], modelType: T.Type) -> [T] {
        var models: [T] = []
        documents.forEach { document in
            if let model = decode(modelType: modelType, data: document.data()) {
                models.append(model)
            }
        }
        debugPrint("result = \(models)")
        return models
    }
    
    private static func decode<T: Codable>(modelType: T.Type, data: [String: Any]) -> T? {
        var result: T?
        do {
            result = try FirestoreDecoder().decode(modelType, from: data)
        } catch {
            result = nil
            debugPrint("failed to decode : \(error)")
        }
        return result
    }
    
    private static func encode<T: Codable>(model: T) -> [String : Any]? {
        let optionalData: [String: Any]?
        do {
            optionalData = try FirestoreEncoder().encode(model)
        } catch {
            debugPrint("failed to encode : \(error)")
            optionalData = nil
        }
        return optionalData
    }
}
