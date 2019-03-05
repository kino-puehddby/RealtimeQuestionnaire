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
    case questionnaire = "Questionnaire"
    case user = "User"
    case community = "Community"
}

public enum APIError: Error {
    case network
    case server(Int)
    case unknown(String)
    case decodeError
}

extension Reactive where Base: Firestore {
    /**
     データの追加
     */
    public func setData<T: Codable>(model: T, collectionRef: CollectionReference, documentRef: DocumentReference? = nil) -> Single<()> {
        return Single.create { observer in
            let optionalData: [String: Any]?
            do {
                optionalData = try FirestoreEncoder().encode(model)
            } catch {
                debugPrint(APIError.decodeError)
                observer(.error(error))
                optionalData = nil
            }
            guard let data = optionalData else {
                observer(.error(APIError.unknown(L10n.Error.unknown)))
                return Disposables.create()
            }
            if let documentRef = documentRef {
                // DocumentID を指定
                documentRef
                    .setData(data) { error in
                        if let error = error {
                            observer(.error(error))
                        } else {
                            observer(.success(()))
                        }
                    }
            } else {
                // DocumentID を自動で割り振る
                collectionRef
                    .addDocument(data: data) { error in
                        if let error = error {
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
    public func update<T: Codable>(new model: T, documentRef: DocumentReference) -> Single<()> {
        return Single.create { observer in
            let optionalData: [String: Any]?
            do {
                optionalData = try FirestoreEncoder().encode(model)
            } catch {
                debugPrint(APIError.decodeError)
                observer(.error(error))
                optionalData = nil
            }
            guard let data = optionalData else {
                observer(.error(APIError.unknown(L10n.Error.unknown)))
                return Disposables.create()
            }
            documentRef.updateData(data) { error in
                if let error = error {
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
    public func getArray<T: Codable>(_ type: T.Type, collectionRef: CollectionReference) -> Single<[T]> {
        return Single.create { observer in
            collectionRef
                .getDocuments { snapshot, error in
                    if let error = error {
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
                            debugPrint(APIError.decodeError)
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
    public func get<T: Codable>(_ type: T.Type, documentRef: DocumentReference) -> Single<T> {
        return Single.create { observer in
            documentRef
                .getDocument { snapshot, error in
                    if let error = error {
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
                        debugPrint(APIError.decodeError)
                        observer(.error(error))
                    }
            }
            return Disposables.create()
        }
    }
    
    /**
     特定の Model（配列）を監視
     */
    public func observeArray<T: Codable>(_ type: T.Type, collectionRef: CollectionReference) -> Observable<[T]> {
        return Observable.create { observer in
            collectionRef
                .addSnapshotListener { snapshot, error in
                    if let error = error {
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
                            debugPrint(APIError.decodeError)
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
    public func observeModel<T: Codable>(_ type: T.Type, documentRef: DocumentReference) -> Observable<T> {
        return Observable.create { observer in
            documentRef
                .addSnapshotListener { snapshot, error in
                    if let error = error {
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
                        debugPrint(APIError.decodeError)
                        observer.on(.error(error))
                    }
            }
            return Disposables.create()
        }
    }
}
