class MyLocation {
  late num? latitude;
  late num? longitude;
  late String? type;
  late num? distance;
  late Map? realData;
  late String? name;
  late String? number;
  late String? postalCode;
  late String? street;
  late num? confidence;
  late String? region;
  late String? regionCode;
  late String? county;
  late String? locality;
  late String? administrativeArea;
  late String? country;
  late String? countryCode;
  late String? continent;
  late String? label;

  // ignore: non_constant_identifier_names
  MyLocation(
      {this.administrativeArea,
      this.confidence,
      this.continent,
      this.country,
      this.countryCode,
      this.realData,
      this.county,
      this.distance,
      this.label,
      this.latitude,
      this.locality,
      this.longitude,
      this.name,
      this.number,
      this.postalCode,
      this.region,
      this.regionCode,
      this.street,
      this.type});

  /*  {data: [{latitude: -33.943385, longitude: 151.227159, type: address, distance: 0.02,
   name: 415 Bunnerong Road, number: 415, postal_code: 2035, street: Bunnerong Road,
  confidence: 0.8, region: New South Wales, region_code: NSW, county: Botany Bay,
  locality: Eastgardens, administrative_area: Eastgardens, neighbourhood: null,
  country: Australia, country_code: AUS, continent: Oceania, label: 415 Bunnerong Road,
  Eastgardens, NSW, Australia}, {latitude: -33.943311, longitude: 151.227573,
  type: address, distance: 0.055, name: 361 Bunnerong Road, number: 361,
  postal_code: 2035, street: Bunnerong Road, confidence: 0.8, region: New South Wales,
  region_code: NSW, county: Randwick, locality: Maroubra, administrative_area: Maroubra,
  neighbourhood: null, country: Australia, country_code: AUS, continent: Oceania,
  label: 361 Bunnerong Road, Maroubra, NSW, Australia},
  {latitude: -33.943182, longitude: 151.227583, type: address, distance: 0.057,
  name: 359 Bunnerong Road, number: 359, postal_code: 2035, street: Bunnerong Road, */

  MyLocation parseFromHttpResults(Map data) {
    Map realData = data["data"].first;
    return MyLocation(
      realData: realData,
      latitude: realData["latitude"],
      longitude: realData["longitude"],
      administrativeArea: realData["administrative_area"],
      confidence: realData["confidence"],
      continent: realData["continent"],
      country: realData["country"],
      countryCode: realData["country_code"],
      county: realData["county"],
      distance: realData["distance"],
      label: realData["label"],
      locality: realData["locality"],
      name: realData["name"],
      number: realData["number"],
      postalCode: realData["postal_code"],
      region: realData["region"],
      regionCode: realData["region_code"],
      street: realData["street"],
      type: realData["type"],
    );
  }

  MyLocation parseFromFirebaseMap(Map data) {
    return MyLocation(
      realData: data,
      latitude: data["latitude"],
      longitude: data["longitude"],
      administrativeArea: data["administrative_area"],
      confidence: data["confidence"],
      continent: data["continent"],
      country: data["country"],
      countryCode: data["country_code"],
      county: data["county"],
      distance: data["distance"],
      label: data["label"],
      locality: data["locality"],
      name: data["name"],
      number: data["number"],
      postalCode: data["postal_code"],
      region: data["region"],
      regionCode: data["region_code"],
      street: data["street"],
      type: data["type"],
    );
  }
}
