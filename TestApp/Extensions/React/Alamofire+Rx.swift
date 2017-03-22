//
//  Alamofire+Rx.swift
//  TestApp
//
//  Created by Ozgur on 28/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import AlamofireObjectMapper
import Alamofire
import ObjectMapper
import RxAlamofire
import RxSwift

// MARK: SessionManager

extension Reactive where Base: SessionManager {
  
  public func responseObject<T: Mappable>(_ method: Alamofire.HTTPMethod,
                             _ url: URLConvertible,
                             _ parameters: [String: Any]? = nil,
                             encoding: ParameterEncoding = JSONEncoding.default,
                             headers: [String: String]? = nil
    )
    -> Observable<(HTTPURLResponse, T)>
  {
    return request(
      method,
      url,
      parameters: parameters,
      encoding: encoding,
      headers: headers
      ).flatMap { request in
        return request.rx.responseObject()
    }
  }
  
  public func object<T: Mappable>(_ method: Alamofire.HTTPMethod,
                     _ url: URLConvertible,
                     _ parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = JSONEncoding.default,
                     headers: [String: String]? = nil
    )
    -> Observable<T>
  {
    return request(
      method,
      url,
      parameters: parameters,
      encoding: encoding,
      headers: headers
      )
      .flatMap { request in
        return request.rx.object()
    }
  }
  
  public func responseObjectArray<T: Mappable>(_ method: Alamofire.HTTPMethod,
                                  _ url: URLConvertible,
                                  _ parameters: [String: Any]? = nil,
                                  keyPath: String? = nil,
                                  encoding: ParameterEncoding = JSONEncoding.default,
                                  headers: [String: String]? = nil
    )
    -> Observable<(HTTPURLResponse, [T])>
  {
    return request(
      method,
      url,
      parameters: parameters,
      encoding: encoding,
      headers: headers
      ).flatMap { request in
        return request.rx.responseObjectArray(keyPath: keyPath)
    }
  }
  
  public func objectArray<T: Mappable>(_ method: Alamofire.HTTPMethod,
                          _ url: URLConvertible,
                          _ parameters: [String: Any]? = nil,
                          keyPath: String? = nil,
                          encoding: ParameterEncoding = JSONEncoding.default,
                          headers: [String: String]? = nil
    )
    -> Observable<[T]>
  {
    return request(
      method,
      url,
      parameters: parameters,
      encoding: encoding,
      headers: headers
      ).flatMap { request in
        return request.rx.objectArray(keyPath: keyPath)
    }
  }
}

// MARK: DataRequest

extension Reactive where Base: DataRequest {
  
  func responseObject<T: Mappable>(queue: DispatchQueue? = nil, keyPath: String? = nil,
                      mapToObject object: T? = nil, context: MapContext? = nil)
    -> Observable<(HTTPURLResponse, T)>
  {
    return Observable.create { observer in
      let dataRequest = self.base.responseObject(
        queue: queue, keyPath: keyPath, mapToObject: object, context: context,
        completionHandler: { packedResponse in
          
          switch packedResponse.result {
          case .success(let result):
            if let httpResponse = packedResponse.response {
              observer.on(.next(httpResponse, result))
            }
            else {
              observer.on(.error(RxAlamofireUnknownError))
            }
            observer.on(.completed)
          case .failure(let error):
            observer.on(.error(error as Error))
          }
      })
      return Disposables.create {
        dataRequest.cancel()
      }
    }
  }
  
  func object<T: Mappable>(queue: DispatchQueue? = nil, keyPath: String? = nil,
              mapToObject object: T? = nil, context: MapContext? = nil)
    -> Observable<T>
  {
    return Observable.create { observer in
      let dataRequest = self.base
        .responseObject(completionHandler: {
          (packedResponse: DataResponse<T>) in
          switch packedResponse.result {
          case .success(let result):
            if let _ = packedResponse.response {
              observer.on(.next(result))
            }
            else {
              observer.on(.error(RxAlamofireUnknownError))
            }
            observer.on(.completed)
          case .failure(let error):
            observer.on(.error(error as Error))
          }
        })
      return Disposables.create {
        dataRequest.cancel()
      }
    }
  }
  
  func responseObjectArray<T: Mappable>(queue: DispatchQueue? = nil, keyPath: String? = nil,
                           context: MapContext? = nil)
    -> Observable<(HTTPURLResponse, [T])>
  {
    return Observable.create { observer in
      let dataRequest = self.base.responseArray(
        queue: queue, keyPath: keyPath, context: context,
        completionHandler: {
          (packedResponse: DataResponse<[T]>) in
          
          switch packedResponse.result {
          case .success(let result):
            if let httpResponse = packedResponse.response {
              observer.on(.next(httpResponse, result))
            }
            else {
              observer.on(.error(RxAlamofireUnknownError))
            }
            observer.on(.completed)
          case .failure(let error):
            observer.on(.error(error as Error))
          }
      })
      return Disposables.create {
        dataRequest.cancel()
      }
    }
  }
  
  func objectArray<T: Mappable>(queue: DispatchQueue? = nil, keyPath: String? = nil,
                   context: MapContext? = nil) -> Observable<[T]>
  {
    return Observable.create { observer in
      let dataRequest = self.base.validate(statusCode: 200 ..< 300)
        .responseArray(
          queue: queue, keyPath: keyPath, context: context,
          completionHandler: {
            (packedResponse: DataResponse<[T]>) in
            switch packedResponse.result {
            case .success(let result):
              if let _ = packedResponse.response {
                observer.on(.next(result))
              }
              else {
                observer.on(.error(RxAlamofireUnknownError))
              }
              observer.on(.completed)
            case .failure(let error):
              observer.on(.error(error as Error))
            }
        })
      return Disposables.create {
        dataRequest.cancel()
      }
    }
  }
}

extension DataRequest {
  
  func validate(_ contentType: String, _ statusCode: Int) -> Self {
    return validate(statusCode: [statusCode]).validate(contentType: [contentType])
  }
}
