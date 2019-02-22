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
import RxSwift

public enum CollectionKey: String {
    case questionnaireListGet = "QuestionnaireList"
}

enum APIError: Error {
    case network
    case server(Int)
    case unknown(String)
}

extension Reactive where Base: Firestore {
    // TODO: Codable -> DatabaseCollection に replace する
    
    /**
     データの追加
     */
    public func setData<T: Codable>(model: T, collectionKey: CollectionKey, documentPath: String?) -> Single<()> {
        return Single.create { observer in
            let db = Firestore.firestore()
            let optionalData: [String: Any]?
            do {
                optionalData = try FirestoreEncoder().encode(model)
            } catch {
                debugPrint(error)
                observer(.error(error))
                optionalData = nil
            }
            guard let data = optionalData else {
                observer(.error(APIError.unknown(L10n.Error.unknown)))
                return Disposables.create()
            }
            if let documentPath = documentPath {
                // DocumentID を指定
                db.collection(collectionKey.rawValue)
                    .document(documentPath).setData(data) { error in
                        if let error = error {
                            debugPrint(error)
                            observer(.error(error))
                        } else {
                            observer(.success(()))
                        }
                    }
            } else {
                // DocumentID を自動で割り振る
                db.collection(collectionKey.rawValue)
                    .addDocument(data: data) { error in
                        if let error = error {
                            debugPrint(error)
                            observer(.error(error))
                        } else {
                            observer(.success(()))
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    /**
     データの更新
     */
    public func update<T: Codable>(new model: T, collectionKey: CollectionKey, documentPath: String) -> Single<()> {
        return Single.create { observer in
            let db = Firestore.firestore()
            let documentRef = db.collection(collectionKey.rawValue).document(documentPath)
            let optionalData: [String: Any]?
            do {
                optionalData = try FirestoreEncoder().encode(model)
            } catch {
                debugPrint(error)
                observer(.error(error))
                optionalData = nil
            }
            guard let data = optionalData else {
                observer(.error(APIError.unknown(L10n.Error.unknown)))
                return Disposables.create()
            }
            documentRef.updateData(data) { error in
                if let error = error {
                    debugPrint(error)
                    observer(.error(error))
                } else {
                    observer(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    /**
     データの取得（配列）
     */
    public func getArray<T: Codable>(_ type: T.Type, collectionKey: CollectionKey) -> Single<[T]> {
        return Single.create { observer in
            let db = Firestore.firestore()
            let collectionRef = db.collection(collectionKey.rawValue)
            collectionRef
                .getDocuments { snapshot, error in
                    if let error = error {
                        debugPrint(error)
                        observer(.error(error))
                        return
                    }
                    guard let snapshot = snapshot else {
                        observer(.error(APIError.unknown(L10n.Error.unknown)))
                        return
                    }
                    let results = snapshot.documents.compactMap({ document -> T? in
                        do {
                            return try FirebaseDecoder().decode(type, from: document.data())
                        } catch {
                            debugPrint(error)
                            return nil
                        }
                    })
                    observer(.success(results))
                }
            return Disposables.create()
        }
    }
    
    /**
     データの取得
     */
    public func get<T: Codable>(_ type: T.Type, collectionKey: CollectionKey) -> Single<T> {
        return Single.create { observer in
            let db = Firestore.firestore()
            let collectionRef = db.collection(collectionKey.rawValue)
            let documentRef = collectionRef.document("") // FIXME: 汎用化
            documentRef
                .getDocument { snapshot, error in
                    if let error = error {
                        debugPrint(error)
                        observer(.error(error))
                        return
                    }
                    guard let data = snapshot?.data() else {
                        observer(.error(APIError.unknown(L10n.Error.unknown)))
                        return
                    }
                    do {
                        let result = try FirebaseDecoder().decode(type, from: data)
                        observer(.success(result))
                    } catch {
                        debugPrint(error)
                        observer(.error(error))
                    }
            }
            return Disposables.create()
        }
    }
    
    /**
     特定の Model（配列）を監視
     */
    public func observeArray<T: Codable>(_ type: T.Type, collectionKey: CollectionKey) -> Observable<[T]> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            let collectionRef = db.collection(collectionKey.rawValue)
            collectionRef
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        debugPrint(error)
                        observer.on(.error(error))
                        return
                    }
                    guard let snapshot = snapshot else {
                        observer.on(.error(APIError.unknown(L10n.Error.unknown)))
                        return
                    }
                    let results = snapshot.documents.compactMap { document -> T? in
                        do {
                            return try FirestoreDecoder().decode(type, from: document.data())
                        } catch {
                            // TODO: error handling
                            debugPrint(error)
                            return nil
                        }
                    }
                    observer.on(.next(results))
                }
            return Disposables.create()
        }
    }
    
    /**
     特定の Model を監視
     */
    public func observeModel<T: Codable>(_ type: T.Type, collectionKey: CollectionKey) -> Observable<T> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            let collectionRef = db.collection(collectionKey.rawValue)
            let documentRef = collectionRef.document("") // FIXME: 汎用化
            documentRef
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        debugPrint(error)
                        observer.on(.error(error))
                        return
                    }
                    guard let data = snapshot?.data() else {
                        observer.on(.error(APIError.unknown(L10n.Error.unknown)))
                        return
                    }
                    do {
                        let result = try FirestoreDecoder().decode(type, from: data)
                        observer.on(.next(result))
                    } catch {
                        debugPrint(error)
                        observer.on(.error(error))
                    }
            }
            return Disposables.create()
        }
    }
}
