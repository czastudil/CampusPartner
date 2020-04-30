# CampusPartner
Route-planning applications such as Google Maps and Apple Maps are used by millions of people each month. However, these mapping applications are optimized for vehicle navigation, and although they provide pedestrian routing, the route customization options aren’t sufficient for pedestrian users, especially those with mobility impairments. CampusPartner is an assistive iOS application which was designed with the purpose of supporting people with mobility impairments in planning and previewing their walking routes. By viewing routes in advance, users can see an overview and detailed information about them as well as turn-by-turn instructions. CampusPartner integrates existing services, GraphHopper, OpenStreetMap, and Mapbox, to provide navigation functionality. Users are able to create a profile upon opening the app, which will include information such as obstacles and road types to avoid, as well as their bookmarked or most commonly used routes. For example, if someone was looking for a route from one side of campus to the other and they couldn’t take stairs due to a mobility impairment, this app would assist them in determining the best route to take or notify them if they should look for an alternative form of transportation, such as a bus. Additionally, users are able to correct missing or inaccurate information, such as the absence of stairs on the map or temporary obstacles.

# How to Run the App
1. Clone this repository
2. If needed, install Carthage in order to install all of the necessary frameworks: [Carthage Installation Directions](https://github.com/Carthage/Carthage#installing-carthage)
3. Run the following command in your terminal ```carthage update --platform iOS```
4. Create an account with [Mapbox](https://account.mapbox.com/auth/signup/) & generate an API key
5. Create an account with [GraphHopper](https://graphhopper.com/dashboard/#/register) & generate an API key

   NOTE: In order to use the flexible features of the GraphHopper API (i.e. avoiding stairs) you must have a paid account 6 

6. Edit the scheme of the Xcode project to set the environment variables for the API keys
  * This can be done by editing the XML file directly or indirectly by navigating to Product-Scheme-Edit Scheme-Arguments
    * If editing the scheme directly, navigate to the ```EnvironmentVariables``` entity and replace the placeholder text there with your API keys
    * If editing the scheme indirectly, just replace the placeholder text with your API keys
7. Build the project with iPhone 11 simulator chosen

# Acknowledgements
I would also like to acknowledge the various open source technologies I utilized in my application. [GraphHopper](https://www.graphhopper.com/) provided the routing functionality without which this application’s functionality would be severely lacking. I would also like to thank GraphHopper for providing a discount for access to the API. [OpenStreetMap](https://www.graphhopper.com/) was used as the underlying data source, provided accessibility information used in generating routes and [Mapbox](https://www.mapbox.com/) was used to display the map interface. To access the GraphHopper routing API, I utilized the [GraphHopper Routing Swift Framework](https://github.com/rmnblm/GraphHopperRouting) created by Roman Blum and Phil Schilter from HSR University of Applied Sciences. Lastly, the [Go Map!!](https://github.com/bryceco/GoMap) application created by Bryce Cogswell was used to facilitate users’ edits and additions to OpenStreetMap from my application.

