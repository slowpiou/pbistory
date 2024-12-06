void Main() {
#if DEPENDENCY_NADEOSERVICES
	NadeoServices::AddAudience("NadeoLiveServices");
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
      yield();
    }
#endif
    string mapname = "";
    string author = "";
    string uid = "";
    uint AT;
    uint gold;
    uint silver ;
    uint bronze;

	int pbest = -1;

	bool is_idle = true;
    string folder_location = IO::FromStorageFolder("data");
    while (true) {
        auto app = GetApp();
        auto map = app.RootMap;

        bool did_enter_new_map = map !is null && map.MapInfo.MapUid != uid && app.Editor is null;

        if (did_enter_new_map) {
            uid = map.MapInfo.MapUid;
            mapname = map.MapInfo.Name;
            author = map.MapInfo.AuthorNickName;
            AT = map.MapInfo.TMObjective_AuthorTime;
            gold = map.MapInfo.TMObjective_GoldTime;
            silver = map.MapInfo.TMObjective_SilverTime;
            bronze = map.MapInfo.TMObjective_BronzeTime;
            is_idle = false;
            continue;
        } else if (map is null && !is_idle) {
            is_idle = true;
        } else if (map !is null && !did_enter_new_map) {
            if (MapInfo::GetCurrentMapInfo().PersonalBestTime > 0 && (pbest == -1 || MapInfo::GetCurrentMapInfo().PersonalBestTime < pbest)) {
                pbest = MapInfo::GetCurrentMapInfo().PersonalBestTime;
                if (!IO::FileExists(folder_location + "/" + uid + '.json')) {
                    auto pbs = Json::Array();
                    auto content = Json::Object();
                    content["uid"] = uid;
                    content["mapname"] = mapname;
                    content["author"] = author;
                    content["updatedAt"] = Time::Stamp;
                    content["AT"] = AT;
                    content["gold"] = gold;
                    content["silver"] = silver;
                    content["bronze"] = bronze;
                    content["date"] = MapInfo::GetCurrentMapInfo().TOTDDate;
                    auto newpb = Json::Object();
                    newpb["finishes"] = GrindingStats::GetTotalFinishes();
                    newpb["attempts"] = GrindingStats::GetTotalResets();
                    newpb["hunt_time"] = GrindingStats::GetTotalTime();
                    newpb["rank"] = get_player_position(uid, pbest);
                    newpb["ats"] = get_at_count(uid);
                    newpb["wr"] = get_wr(uid);
                    newpb["players_count"] = MapInfo::GetCurrentMapInfo().NbPlayers + 1;
                    newpb["date"] = Time::Stamp;
                    newpb["time"] = pbest;
                    pbs.Add(newpb);
                    content["pbs"] = pbs;
                    Json::ToFile(folder_location + "/" + uid + '.json', content);
                    UI::ShowNotification("New map \\$f66" + mapname + "\\$g and PB: \\$f66" + pbest + "\\$g saved!", 3000);
                } else {
                    auto map_data = Json::FromFile(folder_location + "/" + uid + '.json');   
                    auto content = Json::Object();
                    content["uid"] = map_data.Get("uid");
                    content["mapname"] = map_data.Get("mapname");
                    content["author"] = map_data.Get("author");
                    content["updatedAt"] = map_data.Get("updatedAt");
                    content["AT"] = map_data.Get("AT");
                    content["gold"] = map_data.Get("gold");
                    content["silver"] = map_data.Get("silver");
                    content["bronze"] = map_data.Get("bronze");
                    content["date"] = MapInfo::GetCurrentMapInfo().TOTDDate;
                    auto pbs = Json::Array();
                    pbs = map_data.Get("pbs");
                    auto newpb = Json::Object();
                    newpb["finishes"] = GrindingStats::GetTotalFinishes();
                    newpb["attempts"] = GrindingStats::GetTotalResets();
                    newpb["hunt_time"] = GrindingStats::GetTotalTime();
                    newpb["rank"] = get_player_position(uid,pbest);;
                    newpb["ats"] = get_at_count(uid);
                    newpb["wr"] = get_wr(uid);
                    newpb["players_count"] = MapInfo::GetCurrentMapInfo().NbPlayers + 1;
                    newpb["date"] = Time::Stamp;
                    newpb["time"] = pbest;
                    pbs.Add(newpb);
                    content["pbs"] = pbs;
                    Json::ToFile(folder_location + "/" + uid + '.json', content);
                    UI::ShowNotification("New PB: " + pbest +" saved!", 3000);
                }
                
            }
        }
        yield();

    }
    
};

int get_player_position(const string &in map_uid, int &in record) {
    string url = NadeoServices::BaseURLLive()
            + "/api/token/leaderboard/group/Personal_Best/map/"
            + map_uid
            + "/surround/0/0?score="
            +  record;
    Net::HttpRequest@ req = NadeoServices::Get("NadeoLiveServices", url);

    req.Start();

    while(!req.Finished()) yield();

    Json::Value json = Json::Parse(req.String());
    Json::Value tops = json['tops'];
    Json::Value world_top = tops[0]['top'];
    int position = world_top[0].Get('position');
    return position;
}


int get_wr(const string &in map_uid) {
    string url = NadeoServices::BaseURLLive()
            + "/api/token/leaderboard/group/Personal_Best/map/"
            + map_uid
            + "/top?offset=0&length=1&onlyworld=1";
    Net::HttpRequest@ req = NadeoServices::Get("NadeoLiveServices", url);

    req.Start();

    while(!req.Finished()) yield();

    Json::Value json = Json::Parse(req.String());
    Json::Value tops = json['tops'];
    Json::Value world_top = tops[0]['top'];
    int wr = world_top[0].Get('score');
    return wr;
}

int get_at_count(const string &in map_uid) {
    string url = NadeoServices::BaseURLLive()
            + "/api/token/leaderboard/group/Personal_Best/map/"
            + map_uid
            + "/medals";
    Net::HttpRequest@ req = NadeoServices::Get("NadeoLiveServices", url);

    req.Start();

    while(!req.Finished()) yield();

    Json::Value json = Json::Parse(req.String());
    Json::Value medals = json['medals'];
    Json::Value closestAT = medals[0].Get("score");
    int ats = get_player_position(map_uid, closestAT);
    return ats - 1;
}
