# Drag Racing Calculator

A single-screen Flutter app to estimate 1/4-mile elapsed time (ET) and trap speed, and compute per-gear speeds at a given shift RPM.

## Features
- Weight units toggle: kg / lb
- Inputs: total vehicle weight, flywheel horsepower, tire diameter (inches), diff ratio, number of gears (2–6), per-gear ratios, shift RPM
- Outputs:
	- Predicted ET (s) using a common approximation
	- Predicted trap speed (mph and km/h)
	- Per-gear speeds at the selected shift RPM (mph and km/h)
 - Track length selection: 1/8 mile, 1000 ft, or 1/4 mile (ET and trap speed scaled accordingly)

## Formulas
- Unit conversions:
	- lb = kg × 2.2046226218
	- km/h = mph × 1.609344
- ET prediction: `ET = 6.290 × (Weight_lb / HP)^(1/3)`
- Trap speed: `MPH = 234 × (HP / Weight_lb)^(1/3)`
- Speed at RPM per gear: `MPH = (RPM × tire_diameter_in) / (gear_ratio × diff_ratio × 336)`

Track length scaling (approximate, varies by combo):
- 1/8 mile ET ≈ 0.64 × 1/4 mile ET
- 1000 ft ET ≈ 0.91 × 1/4 mile ET
- 1/8 mile MPH ≈ 0.80 × 1/4 mile MPH
- 1000 ft MPH ≈ 0.94 × 1/4 mile MPH

These formulas are common approximations used in drag racing calculators and provide reasonable ballpark figures. Actual results depend on traction, aerodynamics, drivetrain losses, and tune.

## How to run
```powershell
# From the workspace root
cd drag_calc
flutter pub get
flutter run -d chrome   # or use a connected Android device
```

## Next steps (optional)
- Add vehicle profiles and save/load presets
- Add more calculators (e.g., wheel vs flywheel HP, DA correction, 60ft impact, gear spacing/shift-point optimizer)
- Add ads/subscription similar to your other app
- Export/share calculation summaries
