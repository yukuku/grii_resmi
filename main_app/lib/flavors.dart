const FLAVOR = String.fromEnvironment("FLAVOR");

class Flavor {
  final String functionsPrefix;

  Flavor(this.functionsPrefix);

  static Flavor get current {
    switch (FLAVOR) {
      case "qa":
        return Flavor("http://10.0.2.2:5001/pulau-kreta/us-central1");
      case "prod":
        return Flavor("https://us-central1-pulau-kreta.cloudfunctions.net");
      default:
        throw UnsupportedError("Flavor is not defined or supported: $FLAVOR");
    }
  }
}
