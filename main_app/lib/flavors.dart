const FLAVOR = String.fromEnvironment("FLAVOR");

class Flavor {
  final String name;
  final String functionsPrefix;
  final String pillarApiUrl = "https://www.buletinpillar.org/prog/api/app-apis.php";
  final String salamisApiUrl = "https://pulau-salamis.herokuapp.com/";
  final String imageProxyHost = "pulau-salamis.herokuapp.com";

  Flavor({
    required this.name,
    required this.functionsPrefix,
  });

  static Flavor get current {
    switch (FLAVOR) {
      case "qa":
        return Flavor(
          name: 'qa',
          functionsPrefix: 'http://10.0.2.2:5001/pulau-kreta/us-central1',
        );
      default:
        return Flavor(
          name: 'prod',
          functionsPrefix: 'https://us-central1-pulau-kreta.cloudfunctions.net',
        );
    }
  }
}
