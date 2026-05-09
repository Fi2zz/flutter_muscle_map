import 'models.dart';
import 'malefrontpaths.dart';
import 'malebackpaths.dart';
import 'femalefrontpaths.dart';
import 'femalebackpaths.dart';

class BodyPathProvider {
  static List<BodyPartPathData> paths(BodyGender gender, BodySide side) {
    switch ((gender, side)) {
      case (BodyGender.male, BodySide.front):
        return MaleFrontPaths.paths;
      case (BodyGender.male, BodySide.back):
        return MaleBackPaths.paths;
      case (BodyGender.female, BodySide.front):
        return FemaleFrontPaths.paths;
      case (BodyGender.female, BodySide.back):
        return FemaleBackPaths.paths;
    }
  }

  static BodyViewBox viewBox(BodyGender gender, BodySide side) {
    switch ((gender, side)) {
      case (BodyGender.male, BodySide.front):
        return BodyViewBox.maleFront;
      case (BodyGender.male, BodySide.back):
        return BodyViewBox.maleBack;
      case (BodyGender.female, BodySide.front):
        return BodyViewBox.femaleFront;
      case (BodyGender.female, BodySide.back):
        return BodyViewBox.femaleBack;
    }
  }
}
