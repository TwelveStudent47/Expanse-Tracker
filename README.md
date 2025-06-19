# 💰 Expense Tracker - Személyes Pénzügyi Tracker

Egy iOS alkalmazás személyes pénzügyek nyomon követésére, SwiftUI-ban fejlesztve.

## 📱 Funkcionalitás

- **Real-Time egyenleg követés**
- **Tranzakciók kezelése** - Bevételek és kiadások egyszerű rögzítése
- **Kategorizálás** - Előre definiált kategóriák emoji-kkal
- **Havi statisztikák** - Havi bevétel és kiadás összesítése
- **Dátum kezelés** - Tranzakciók időrendi rendezése
- **Adatok megőrzése** - Automatikus mentés UserDefaults-ban
- **Swipe to delete** - Egyszerű tranzakció törlés

## 🚀 Képernyőképek


### Főképernyő
- Aktuális egyenleg megjelenítése
- Havi bevétel/kiadás összesítő
- Tranzakciók listája időrendi sorrendben

### Új tranzakció hozzáadása
- Megnevezés és összeg megadása
- Kategória kiválasztása
- Dátum beállítása
- Bevétel/kiadás típus választás

## 🛠 Technikai részletek

### Követelmények
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

### Felhasznált technológiák
- **SwiftUI** 
- **MVVM architektúra** 
- **ObservableObject** 
- **UserDefaults** 
- **Combine** 

## 📦 Telepítés és futtatás

### 1. Repository klónozása
```bash
git clone https://github.com/[felhasznalonev]/expense-tracker.git
cd expense-tracker
```

### 2. Xcode-ban megnyitás
```bash
open Expense-Tracker.xcodeproj
```

### 3. Futtatás
- Válassz egy szimulátort vagy eszközt
- Nyomd meg a **Cmd + R** billentyűkombinációt

## 💡 Használat

### Új tranzakció hozzáadása
1. Kattints a **+** gombra a navigációs sávban
2. Töltsd ki a szükséges mezőket:
   - **Megnevezés**: Mi volt a tranzakció
   - **Összeg**: Mennyi pénzről van szó
   - **Kategória**: Válassz a listából
   - **Dátum**: Mikor történt
   - **Bevétel toggle**: Be/ki kapcsolás
3. Kattints a **Mentés** gombra

### Tranzakció törlése
- Swipe-olj balra egy tranzakción
- Kattints a **Törlés** gombra

### Kategóriák
- 🍕 Étel
- 🚗 Közlekedés  
- 🎬 Szórakozás
- 🛍️ Vásárlás
- 💰 Fizetés
- 📝 Egyéb

## 🔧 Testreszabás

### Új kategória hozzáadása
1. Nyisd meg a `ContentView.swift` fájlt
2. Bővítsd a `TransactionCategory` enum-ot:
```swift
enum TransactionCategory: String, CaseIterable, Codable {
    case food = "Étel"
    case transport = "Közlekedés"
    // ... meglévő kategóriák
    case newCategory = "Új kategória"  // Új sor
    
    var emoji: String {
        switch self {
        case .food: return "🍕"
        // ... meglévő emoji-k
        case .newCategory: return "🆕"  // Új emoji
        }
    }
}
```

### Pénznem módosítása
A `hu_HU` locale módosításával más pénznemet is használhatsz:
```swift
formatter.locale = Locale(identifier: "en_US") // USD esetén
```

## 🚧 Fejlesztési lehetőségek

- [ ] Grafikonok és statisztikák
- [ ] Export CSV/PDF formátumban
- [ ] Költségvetés tervezés
- [ ] Ismétlődő tranzakciók
- [ ] Touch ID / Face ID védelem
- [ ] iCloud szinkronizáció
- [ ] Widget támogatás
- [ ] Dark mode finomhangolás

## 📄 Licensz

Ez a projekt MIT licensz alatt áll. Részletek a [LICENSE](LICENSE) fájlban.

## 👨‍💻 Szerző

**Laczkó Kevin**
