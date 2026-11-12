# Stage 2.4.3: touch-first Android HUD

Based on a real Android screenshot, remove four small top-right camera buttons. Camera controls are entirely direct touch gestures: one finger drags the map, two fingers pinch to zoom and twist to rotate. The root HUD is touch-transparent outside panels, so map gestures and building placement reach gameplay. Farm/construction tabs and action buttons use larger typography and at least 70px touch targets. Bottom actions panel reflows to two columns on narrow screens and three on wide screens, and is positioned using its calculated minimum height. No save format or production mechanics changed.

Automated headless tests verify UI and simulated two-finger camera gestures. Physical-device visual layout and gesture behavior still require verification.
