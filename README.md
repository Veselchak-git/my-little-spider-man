# My Little Spider-Man

Десктопный companion для macOS: чиби Spider-Man периодически спускается с «потолка» монитора на паутине. Меню в статус-баре, настройки, скины и стили паутины. Интерфейс на русском и английском.

## Стек

|             |                                                  |
| ----------- | ------------------------------------------------ |
| Язык        | Swift 6                                          |
| UI          | AppKit (`NSPanel`, status item, settings window) |
| Графика     | Core Graphics (процедурный рендер, без спрайтов) |
| Сборка      | Swift Package Manager                            |
| Платформа   | macOS 14+ (Apple Silicon)                        |
| Локализация | `Localizable.strings` (en / ru)                  |
| Установщик  | `pkgbuild` + `productbuild` → `.pkg` / `.dmg`    |

Зависимостей из CocoaPods / SPM-пакетов нет — только системные фреймворки `AppKit` и `QuartzCore`.

## Требования

- macOS 14 или новее
- Xcode Command Line Tools (`xcode-select --install`)
- `swift` в `PATH`

## Быстрый старт

```bash
git clone <repo-url>
cd my-little-spider-man
./scripts/buildApp.sh
open "dist/My Little Spider-Man.app"
```

Приложение — agent (`LSUIElement`): иконки в Dock нет, управление через иконку в меню-баре.

## Установщик

Собрать `.pkg` и `.dmg`:

```bash
./installer/buildInstaller.sh
```

Артефакты появятся в `dist/`:

- `MyLittleSpiderMan-<version>.pkg`
- `MyLittleSpiderMan-<version>.dmg`

PKG ставит приложение в `/Applications` и запускает его (см. `installer/scripts/postinstall`).

## Возможности

- Появление / висение / уход с потолка (в т.ч. multi-monitor)
- Скины: Miles, Advanced, Prowler, Tech, Crimson, Uptown, Programmable, Future, Hoodie, Classic
- Стили паутины: Classic, Silk, Twisted, Glow, Venom
- Эмоции глаз (surprise / anger) с интервалом
- Масштаб фигуры, длина паутины, тайминги появления
- Язык: English / Russian

## Структура

```
src/
  app/          # main, AppDelegate
  model/        # настройки, скины, контроллер позы, L10n
  ui/           # SpiderView (extensions), panel, settings
resources/      # Info.plist, en/ru.lproj
scripts/        # buildApp.sh
installer/      # buildInstaller.sh, distribution, postinstall UI
```

## Лицензия

MIT — см. [LICENSE](LICENSE).
