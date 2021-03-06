
V36 Workbench default icon usage
--------------------------------

At least with Workbench 36.1524 (1990-03-20) in Kickstart 36.028 "2.0 Beta"
the icon.library/GetDefDiskObject() is required and has to be implemented.
At least with Kickstart 36.067 "2.0 Beta" the icon.library in included.

- disk: icon 36.201 (31 May 1989) [1.4 Alpha 15]
  - no GetDefDiskObject/PutDefDiskObject
  - no default icons
- disk: icon 36.214 (11 Dec 1989) [1.4 Beta 1]
  - GetDefDiskObject/PutDefDiskObject() always return 0
  - default icon code/data in unused segments
- kick: icon 36.279 (20.4.90) [2.0 Beta (36.067)]
  - GetDefDiskObject/PutDefDiskObject implemented
- kick: icon 36.336 (8.6.90) [2.0 Roms (36.141/143)]
- kick: icon 36.343 (12.9.90) [2.0 Roms (36.207)]


V36 ROM default 4 color settings
--------------------------------

Notice the transition from blue to dark/light gray
(don't get confused by the HTML/CSS color names).

|  color0   |  color1   |  color2   |  color3   | Kickstart                               |
|:----------|:----------|:----------|:----------|:----------------------------------------|
| `#0055AA` | `#FFFFFF` | `#000022` | `#FF8800` | `36.015` (a3ba6116) "1.4 Alpha 15"      |
| `#0055AA` | `#FFFFFF` | `#000022` | `#FF8800` | `36.002` (39779507) "1.4 Alpha 18"      |
| `#0055AA` | `#FFFFFF` | `#000022` | `#FF8800` | `36.016` (bc0ec13f) "1.4 Beta Exp"      |
| `#888888` | `#000000` | `#FFFFFF` | `#6688BB` | `36.028` (b4113910) "2.0 Beta"          |
| `#888888` | `#000000` | `#FFFFFF` | `#6688BB` | `36.067` (e0aa5472) "2.0 Beta"          |
| `#AAAAAA` | `#000000` | `#FFFFFF` | `#6688BB` | `36.141` (1e0d1601) "2.0 Roms (36.141)" |
| `#AAAAAA` | `#000000` | `#FFFFFF` | `#6688BB` | `36.143` (b333d3c6) "2.0 Roms (36.143)" |
| `#AAAAAA` | `#000000` | `#FFFFFF` | `#6688BB` | `36.207` (9a15519d) "2.0 Roms (36.207)" |

| RGB       | CSS          |                 HSL |                     YIQ |
|:----------|:-------------|--------------------:|------------------------:|
| `#000022` | `Black`      | `240, 1.000, 0.067` | `0.015, -0.043, +0.041` |
| `#0055AA` | `MediumBlue` | `210, 1.000, 0.333` | `0.272, -0.306, +0.033` |
| `#6688BB` | `SteelBlue`  | `216, 0.385, 0.567` | `0.516, -0.144, +0.034` |
| `#888888` | `Gray`       | `  0, 0.000, 0.533` | `0.533, +0.000, +0.000` |
| `#AAAAAA` | `DarkGray`   | `  0, 0.000, 0.667` | `0.667, +0.000, +0.000` |
| `#FF8800` | `DarkOrange` | ` 32, 1.000, 0.500` | `0.612, +0.450, -0.067` |
| `#FFFFFF` | `White`      | `  0, 0.000, 1.000` | `1.000, +0.000, +0.000` |


