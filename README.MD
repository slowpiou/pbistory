# pbistory

Simple OpenPlanet Plugin for Trackmania (TM20) that writes PB history to a JSON file.

JSON file location: C:\Users\username\OpenplanetNext\PluginStorage\PBistory\data\\_**mapuid**_.json

Example of output:

```json
{
    "date": "<timestamp>", // TOTD Date or "" if not TOTD
    "mapname": "Downside Up",
    "mapper": "TNTree.",
    "at_time": 19676,
    "uid": "WEa0Z7XFk8zus0YUQuJo8l_HMC",
    "pbs": [
        {
            "time": 19650,
            "hunt_time": "<timestamp>", //integer representing the hunting time from the GrindingStats plugin
            "finishes": 12,
            "attempts": 46,
            "rank": 603,
            "date": "<timestamp>", //integer Time::Stamp
            "ats": 661,
            "wr": 18151,
        },
        ...
    ],
    "updatedAt": "<timestamp>", //integer Time::Stamp
},
```

### Plugins Dependencies

[Grinding Stats](https://openplanet.dev/plugin/grindingstats) by Drek.

[Map Info](https://openplanet.dev/plugin/mapinfo) by Xertrov & MisfitMaid.

### Optional Plugins Dependencies

NadeoServices
