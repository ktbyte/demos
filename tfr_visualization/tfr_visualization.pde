import java.util.*;

float minTfr = 0;
float maxTfr = 10;
int minYear = 1900;
int currentYear = 2018;
int maxYear = 2099;

int currentRegion = 0;
boolean showAllRegions = false;
int currentDrawYear = 0;
int drawStep = 10;
List<Region> regions = new ArrayList<Region>();
Map<String, Region> indexedRegions = new HashMap<String, Region>();
Map<String, Country> countries = new HashMap<String, Country>();

void setup() {
  size(1000, 700);
  background(0);
  stroke(0);

  addRegion("Africa", color(141,211,199));
  addRegion("Americas", color(255,255,179));
  addRegion("Oceania", color(190,186,218));
  addRegion("Asia", color(251,128,114));
  addRegion("Europe", color(128,177,211));

  String countryLines[] = loadStrings("countries.csv");
  
  for (int i = 1; i < countryLines.length; i++) {
    String[] split = countryLines[i].split(",");
    if (split.length >= 6) {
      String countryName = split[0];
      String regionName = split[5];
      addCountry(countryName, regionName);
    }
  }
  
  String lines[] = loadStrings("tfr_by_year.csv");

  for (int i = 1; i < lines.length; i++) {
    String line = lines[i];
    
    String[] data = line.split(",");
    String countryName = data[0];

    float[] parsedData = new float[data.length - 2];
    for (int j = 2; j < data.length; j++) {
      parsedData[j - 2] = float(data[j]);
    }

    if (countries.containsKey(countryName)) {
      countries.get(countryName).setData(parsedData);
    }
  }
  
  redraw();
}

void addRegion(String regionName, color regionColor) {
  Region region = new Region(regionName, regionColor);
  regions.add(region);
  indexedRegions.put(regionName, region);
}

void addCountry(String countryName, String regionName) {
  if (indexedRegions.containsKey(regionName)) {
    Country country = new Country(countryName);
    countries.put(countryName, country);
    indexedRegions.get(regionName).addCountry(country);    
  }
}

void drawRegion(Region region) {
  stroke(region.regionColor);
  fill(region.regionColor);
  for (Country country : region.countries) {
    if (country.hasData()) {
      for (int year = currentDrawYear; year < currentDrawYear + drawStep; year++) {
        float tfr = country.data[year - 1900];
        float nextTfr = country.data[year - 1900 + 1];
        
        if (year < currentYear) {
          line(
              map(year, minYear, maxYear, 0, width),
              map(tfr, minTfr, maxTfr, height, 0),
              map(year + 1, minYear, maxYear, 0, width),
              map(nextTfr, minTfr, maxTfr, height, 0));
        } else {
          point(
              map(year, minYear, maxYear, 0, width),
              map(tfr, minTfr, maxTfr, height, 0));
        }
      }
    }
  }
}

void draw() {
  strokeWeight(2);
  
  if (currentDrawYear < maxYear - drawStep - 1) {
    if (showAllRegions) {
      for (Region region : regions) {
        drawRegion(region);
      }
    } else {
      drawRegion(regions.get(currentRegion));
    }
    
    currentDrawYear += drawStep;
  }
}

void redraw() {
  currentDrawYear = minYear;
  
  background(0);
  
  stroke(100);
  strokeWeight(1);

  for (float tfr = minTfr; tfr < maxTfr; tfr += 1) {
    float y = map(tfr, minTfr, maxTfr, height, 0);
    line(0, y, width, y); 
  }
  
  for (int year = minYear; year < maxYear; year += 20) {
    float x = map(year, minYear, maxYear, 0, width);
    line(x, 0, x, height);
  }
  
  strokeWeight(1);
  
  noStroke();
  fill(0);
  rect(width - 60, 0, width, height);
  
  fill(255);
  textSize(12);
  for (float tfr = minTfr; tfr < maxTfr; tfr += 1) {
    float y = map(tfr, minTfr, maxTfr, height, 0);
    text(nfc(tfr, 0), width - 50, y);
  }
  
  pushMatrix();
  translate(width - 20, height / 2 + 100);
  rotate(-PI / 2);
  textSize(20);
  text("Babies per mother", 0, 0);
  popMatrix();
  
  fill(0);
  rect(0, height - 60, width, height);
  
  fill(255);
  textSize(12);
  for (int year = minYear; year < maxYear; year += 20) {
    float x = map(year, minYear, maxYear, 0, width);
    text(year, x, height - 40);
  }
  
  textSize(20);
  text("Year", width / 2 - 40, height - 10);
  
  fill(0);
  rect(0, 0, width, 60);
  
  for (int i = 0; i < regions.size(); i++) {
    Region region = regions.get(i);
    textSize(20);
    if (currentRegion == i || showAllRegions) {
      fill(region.regionColor);
    } else {
      fill(lerpColor(region.regionColor, color(0), 0.8));
    }
    text(region.name, i * 200 + 20, 40);
  }
}

void keyPressed() {
  if (keyCode == RIGHT) {
    showAllRegions = false;
    currentRegion = (currentRegion + 1) % regions.size();
  } else if (keyCode == LEFT) {
    showAllRegions = false;
    currentRegion = ((currentRegion - 1) % regions.size() + regions.size()) % regions.size();
  } else if (key == ' ') {
    showAllRegions = !showAllRegions;
  }
  redraw();
}

class Country {
  String name;
  float[] data;
  
  public Country(String name) {
    this.name = name;
  }
  
  void setData(float[] data) {
    this.data = data;
  }
   
  boolean hasData() {
    return this.data != null;
  }
}

class Region {
  String name;
  color regionColor;
  List<Country> countries;
  
  Region(String name, color regionColor) {
    this.name = name;
    this.regionColor = regionColor;
    this.countries = new ArrayList<Country>();
  }
  
  void addCountry(Country country) {
    countries.add(country);
  }
}