//
//  GooglePlacesManager.swift
//  GPSearch
//
//  Created by Samy Salama on 2/16/23.
//

import Foundation
import GooglePlaces
import CoreLocation

struct Places {
    let name: String
    let identifier: String
}

final class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init () {}
    
    enum PlacesError {
        case failedToFind
        case failedToGetCoordinates
    }
    
    
    public func findPlaces(query: String,
                           completion: @escaping (Result<[Places], Error>) -> Void) {
        
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) {
            results, error in
            guard let results = results, error == nil else {
                completion(.failure(PlacesError.failedToFind as! Error))
                return
            }
            
            let places: [Places] = results.compactMap({
                Places(name: $0.attributedFullText.string, identifier: $0.placeID)
            })
            
            completion(.success(places))
        }
    
        
    }
    
    public func resolveLocation(for place: Places,
                                completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        client.fetchPlace(fromPlaceID: place.identifier, placeFields: .coordinate, sessionToken: nil) {
            googlePlace, error in
            guard let googlePlaces = googlePlace, error == nil else {
                completion(.failure(PlacesError.failedToGetCoordinates as! Error))
                return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: googlePlaces.coordinate.latitude, longitude: googlePlaces.coordinate.longitude)
            
            completion(.success(coordinate))
            
        }
    }
    
}
