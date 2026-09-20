import '../models/garden_plant_profile.dart';
import 'plant_scan_history.dart';

/// Of een plant in Moestuin History hoort (niet elke lijst-entry).
bool profileQualifiesForHistory(GardenPlantProfile profile) {
  if (profile.harvestedPercent >= 100) return true;
  return plantScanEntries(profile).isNotEmpty;
}
