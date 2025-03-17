//
//  Constants.swift
//  caseloc
//
//  Created by Toygun Çil on 17.03.2025.
//

import UIKit
import CoreLocation
import MapKit

struct Constants {
    
    struct UserDefaults {
        static let savedRouteKey = "savedRoute"
    }
    
    struct Map {
        static let markerIdentifier = "LocationMarker"
        static let initialZoomSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        static let minimumDistanceThreshold: CLLocationDistance = 100
    }
    
    struct UI {
        static let buttonSize: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 25
        static let containerCornerRadius: CGFloat = 10
        static let standardPadding: CGFloat = 20
        static let toastHeight: CGFloat = 40
        static let toastBottomMargin: CGFloat = 80
        static let toastCornerRadius: CGFloat = 10
        static let switchContainerHeight: CGFloat = 40
        static let switchContainerWidth: CGFloat = 170
    }
    
    struct DateFormats {
        static let timeOnly = "HH:mm:ss"
    }
    
    struct Messages {
        static let startingPoint = "Başlangıç Noktası"
        static let trackingOn = "Konum Takibi"
        static let resetRouteTitle = "Rotayı Sıfırla"
        static let resetRouteMessage = "Tüm rota verilerini silmek istediğinizden emin misiniz?"
        static let resetDone = "Rota sıfırlandı"
        static let permissionTitle = "Konum İzni Gerekli"
        static let permissionMessage = "Konumunuzu görebilmek için konum izni vermeniz gerekmektedir. Ayarlar'a giderek izin verebilirsiniz."
        static let unknownAddress = "Bilinmeyen Adres"
        static let addressNotFound = "Adres bilgisi bulunamadı"
        static let addressError = "Adres bilgisi alınamadı"
        static let routeDisplayed = "Rota görüntüleniyor"
        static let routeHidden = "Rota gizlendi"
        static let routeNeedsMorePoints = "Rota oluşturmak için en az 2 nokta gerekir"
        static let routeStatsTitle = "Rota İstatistikleri"
    }
}
