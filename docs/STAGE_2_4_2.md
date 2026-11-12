# Stage 2.4.2: Android touch controls

Android landscape is the sole target platform. Gameplay now separates **Поля** and **Строительство** tabs to reduce clutter on narrow screens. Camera has dedicated ↶, ↷, ＋ and － buttons in addition to single-finger pan and two-finger pinch/rotate. Construction uses the build tab to select a building and tap a valid cell; cancel from the same tab. A multi-finger gesture cannot accidentally place a building on release. The previous save schema and gameplay rules are unchanged.

Automated test `tests/android_controls.gd` checks tabs, buttons, camera state, build selection and multi-finger release. Device screenshots, real touchscreen ergonomics and FPS are still unverified until tested on physical Android hardware.
