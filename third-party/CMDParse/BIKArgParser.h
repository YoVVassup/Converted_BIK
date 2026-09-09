#pragma once

#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include <fstream>
#include <sstream>

struct BIKArg
{
    std::string key;
    std::string value;
    bool isFlag;
};

class BIKArgParser
{
private:
    std::vector<BIKArg> _args;
    std::map<std::string, std::vector<std::string>> _multiValues;
    std::map<std::string, std::string> _configDefaults;

    static std::string ToUpper(const std::string& s)
    {
        std::string result = s;
        std::transform(result.begin(), result.end(), result.begin(), ::toupper);
        return result;
    }

    static std::string Trim(const std::string& s)
    {
        size_t start = s.find_first_not_of(" \t");
        if (start == std::string::npos) return "";
        size_t end = s.find_last_not_of(" \t");
        return s.substr(start, end - start + 1);
    }

    static std::string Unquote(const std::string& s)
    {
        if (s.size() >= 2 && s.front() == '"' && s.back() == '"')
            return s.substr(1, s.size() - 2);
        return s;
    }

    static std::vector<std::string> SplitComma(const std::string& s)
    {
        std::vector<std::string> result;
        std::string current;
        bool inQuotes = false;

        for (size_t i = 0; i < s.size(); i++)
        {
            char c = s[i];
            if (c == '"')
            {
                inQuotes = !inQuotes;
                current += c;
            }
            else if (c == ',' && !inQuotes)
            {
                std::string trimmed = Trim(current);
                if (!trimmed.empty())
                    result.push_back(Unquote(trimmed));
                current.clear();
            }
            else
            {
                current += c;
            }
        }

        std::string trimmed = Trim(current);
        if (!trimmed.empty())
            result.push_back(Unquote(trimmed));

        return result;
    }

    std::string NormalizeKey(const std::string& key) const
    {
        std::string k = ToUpper(key);
        if (k == "G") return "GROUP";
        if (k == "R") return "RES";
        if (k == "I") return "GAME";
        return k;
    }

    void AddValues(const std::string& normalizedKey, const std::string& rawValue)
    {
        std::vector<std::string> parts = SplitComma(rawValue);
        for (size_t i = 0; i < parts.size(); i++)
        {
            std::string val = Trim(parts[i]);
            if (!val.empty())
                _multiValues[normalizedKey].push_back(val);
        }
    }

public:
    std::string GetMode() const
    {
        std::string mode = Get("mode");
        if (mode.empty()) return "CROSS";
        std::string m = ToUpper(mode);
        if (m == "PACK_MO" || m == "PACK_MO_VISION") return "PACK_MO";
        if (m == "PACK_ORIGINAL" || m == "PACK_ORIG") return "PACK_ORIGINAL";
        if (m == "MP3_TO_WAV" || m == "MP3") return "MP3_TO_WAV";
        if (m == "H265" || m == "H264") return "H265";
        if (m == "PREVIEW") return "PREVIEW";
        if (m == "VALIDATE") return "VALIDATE";
        if (m == "RESOLUTION" || m == "RES_CONV") return "RESOLUTION";
        if (m == "MIX_DIFF" || m == "DIFF") return "MIX_DIFF";
        return "CROSS";
    }

    bool WantsListGroups() const { return HasFlag("LIST_GROUPS") || HasFlag("LIST-GROUPS"); }
    bool WantsListFiles() const { return HasFlag("LIST_FILES") || HasFlag("LIST-FILES"); }
    bool WantsVerify() const { return HasFlag("VERIFY"); }
    bool WantsCleanup() const { return HasFlag("CLEANUP"); }
    bool WantsStats() const { return HasFlag("STATS"); }

    void Parse(int argc, char* argv[])
    {
        for (int i = 1; i < argc; i++)
        {
            std::string arg = argv[i];
            if (arg.empty()) continue;
            if (arg[0] != '-') { _args.push_back({arg, arg, false}); continue; }
            if (arg.size() > 1 && arg[1] == '-') arg = arg.substr(1);

            size_t colonPos = arg.find(':');
            if (colonPos != std::string::npos)
            {
                std::string rawKey = arg.substr(1, colonPos - 1);
                std::string rawVal = arg.substr(colonPos + 1);
                std::string normKey = NormalizeKey(rawKey);

                _args.push_back({normKey, rawVal, false});
                AddValues(normKey, rawVal);
            }
            else
            {
                std::string key = arg.substr(1);
                _args.push_back({key, "", true});
            }
        }
    }

    bool HasFlag(const std::string& flag) const
    {
        std::string flagUpper = ToUpper(flag);
        for (size_t i = 0; i < _args.size(); i++)
        {
            if (_args[i].isFlag && ToUpper(_args[i].key) == flagUpper)
                return true;
        }
        return false;
    }

    bool WantsHelp() const { return HasFlag("HELP") || HasFlag("H") || HasFlag("?"); }

    void LoadConfig(const std::string& configPath)
    {
        std::ifstream file(configPath);
        if (!file.is_open()) return;

        std::string line;
        while (std::getline(file, line))
        {
            size_t start = line.find_first_not_of(" \t");
            if (start == std::string::npos) continue;
            line = line.substr(start);

            if (line.empty() || line[0] == '#' || line[0] == ';') continue;
            if (line[0] == '[') continue;

            size_t eq = line.find('=');
            if (eq == std::string::npos) continue;

            std::string key = Trim(line.substr(0, eq));
            std::string val = Trim(line.substr(eq + 1));
            for (auto& c : key) c = (char)tolower((unsigned char)c);
            _configDefaults[key] = val;
        }
    }

    void ApplyConfigDefaults()
    {
        auto cfg = [&](const std::string& key, const std::string& cliKey) {
            auto it = _configDefaults.find(key);
            if (it != _configDefaults.end() && !it->second.empty())
            {
                std::string normKey = ToUpper(cliKey);
                if (_multiValues.find(normKey) == _multiValues.end() || _multiValues[normKey].empty())
                {
                    std::string val = it->second;
                    if (val == "true") val = "1";
                    else if (val == "false") val = "0";
                    AddValues(normKey, val);
                }
            }
        };

        cfg("games", "GAME");
        cfg("groups", "GROUP");
        cfg("resolutions", "RES");
        cfg("mode", "mode");

        auto cfgFlag = [&](const std::string& key, const std::string& flagName) {
            auto it = _configDefaults.find(key);
            if (it != _configDefaults.end())
            {
                std::string v = it->second;
                for (auto& c : v) c = (char)tolower((unsigned char)c);
                if (v == "true" || v == "1")
                {
                    if (!HasFlag(flagName))
                        _args.push_back({flagName, "", true});
                }
            }
        };

        cfgFlag("dry_run", "DRY_RUN");
        cfgFlag("incremental", "INCREMENTAL");
        cfgFlag("retry", "RETRY");
        cfgFlag("overwrite", "OVERWRITE");
    }

    std::string Get(const std::string& key, const std::string& def = "") const
    {
        std::string normKey = NormalizeKey(key);
        auto it = _multiValues.find(normKey);
        if (it != _multiValues.end() && !it->second.empty())
            return it->second[0];
        return def;
    }

    std::vector<std::string> GetAll(const std::string& key) const
    {
        std::string normKey = NormalizeKey(key);
        auto it = _multiValues.find(normKey);
        if (it != _multiValues.end())
            return it->second;
        return std::vector<std::string>();
    }

    std::vector<std::string> GetActiveGames() const
    {
        std::vector<std::string> games;
        std::vector<std::string> gameArgs = GetAll("GAME");
        for (size_t i = 0; i < gameArgs.size(); i++)
        {
            std::string g = ToUpper(gameArgs[i]);
            if (std::find(games.begin(), games.end(), g) == games.end())
                games.push_back(g);
        }
        if (HasFlag("RA1") && std::find(games.begin(), games.end(), "RA1") == games.end())
            games.push_back("RA1");
        if (HasFlag("RA2") && std::find(games.begin(), games.end(), "RA2") == games.end())
            games.push_back("RA2");
        if (HasFlag("RA2YR") && std::find(games.begin(), games.end(), "RA2YR") == games.end())
            games.push_back("RA2YR");
        if (games.empty()) { games.push_back("RA1"); games.push_back("RA2"); games.push_back("RA2YR"); }
        return games;
    }

    std::vector<std::string> GetGroupFilter() const
    {
        std::vector<std::string> groups;
        std::vector<std::string> g = GetAll("GROUP");
        for (size_t i = 0; i < g.size(); i++)
        {
            std::string gu = ToUpper(g[i]);
            if (std::find(groups.begin(), groups.end(), gu) == groups.end())
                groups.push_back(g[i]);
        }
        return groups;
    }

    std::vector<std::string> GetResolutionFilter() const
    {
        std::vector<std::string> res;
        std::vector<std::string> r = GetAll("RES");
        for (size_t i = 0; i < r.size(); i++)
        {
            std::string ru = ToUpper(r[i]);
            if (std::find(res.begin(), res.end(), ru) == res.end())
                res.push_back(r[i]);
        }
        return res;
    }

    bool ShouldIncludeNoFormat() const
    {
        std::vector<std::string> res = GetResolutionFilter();
        for (size_t i = 0; i < res.size(); i++)
        {
            std::string r = ToUpper(res[i]);
            if (r == "NOFORMAT") return true;
            if (r.find('+') != std::string::npos) return true;
        }
        return false;
    }
};