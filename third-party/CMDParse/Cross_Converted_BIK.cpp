#include <iostream>
#include <string>
#include <vector>
#include <filesystem>

#include "BIKArgParser.h"

static void PrintUsage()
{
    std::cout << "Usage: CMDParse.exe [flags]" << std::endl;
    std::cout << std::endl;
    std::cout << "Modes:" << std::endl;
    std::cout << "  --mode:cross          Cross_Converted_BIK (default)" << std::endl;
    std::cout << "  --mode:pack_mo        Pack_Mixes_MO_Vision" << std::endl;
    std::cout << "  --mode:pack_original  Pack_Mixes_Original" << std::endl;
    std::cout << "  --mode:mp3_to_wav     MP3_to_WAV" << std::endl;
    std::cout << "  --mode:h265           H265.bat" << std::endl;
    std::cout << "  --mode:preview        Preview.bat" << std::endl;
    std::cout << "  --mode:validate       Validate_MIX.bat" << std::endl;
    std::cout << "  --mode:resolution     Resolution_Convert.bat" << std::endl;
    std::cout << "  --mode:mix_diff       MIX_Diff.bat" << std::endl;
    std::cout << std::endl;
    std::cout << "Games:   -RA1, -RA2, -RA2YR, -GAME:RA1,RA2" << std::endl;
    std::cout << "Groups:  -GROUP:Original,7wolf, -G:Original" << std::endl;
    std::cout << "Res:     -RES:600p,720p+,1080p, -R:720p" << std::endl;
    std::cout << "Flags:   -DRY_RUN, -INCREMENTAL, -RETRY, -OVERWRITE" << std::endl;
    std::cout << "Aliases: -I: = -GAME:, -G: = -GROUP:, -R: = -RES:" << std::endl;
    std::cout << std::endl;
    std::cout << "Utilities:" << std::endl;
    std::cout << "  --list-groups         List available voice groups" << std::endl;
    std::cout << "  --list-files          List available MP4/BIK files" << std::endl;
    std::cout << "  --verify              Verify all BIKs exist for resolutions" << std::endl;
    std::cout << "  --cleanup             Remove empty BIK files" << std::endl;
    std::cout << "  --stats               Show file statistics" << std::endl;
    std::cout << "  --help                Show this help" << std::endl;
}

static std::string JoinSemicolon(const std::vector<std::string>& v)
{
    std::string result;
    for (size_t i = 0; i < v.size(); i++)
    {
        if (i > 0) result += ";";
        result += v[i];
    }
    return result;
}

static void OutputCross(const BIKArgParser& parser)
{
    std::vector<std::string> games = parser.GetActiveGames();
    std::vector<std::string> groups = parser.GetGroupFilter();
    std::vector<std::string> resolutions = parser.GetResolutionFilter();

    bool hasGames = false;
    for (const auto& g : games)
    {
        if (g == "RA1" || g == "RA2" || g == "RA2YR")
        {
            std::cout << "PROCESS_" << g << "=1" << std::endl;
            hasGames = true;
        }
    }
    if (!hasGames)
    {
        std::cout << "PROCESS_RA1=1" << std::endl;
        std::cout << "PROCESS_RA2=1" << std::endl;
        std::cout << "PROCESS_RA2YR=1" << std::endl;
    }

    if (!groups.empty())
        std::cout << "GROUP_FILTER=" << JoinSemicolon(groups) << std::endl;
    else
        std::cout << "GROUP_FILTER=" << std::endl;

    if (!resolutions.empty())
    {
        std::cout << "RESOLUTION_FILTER=" << JoinSemicolon(resolutions) << std::endl;

        bool nofmt = false;
        for (const auto& r : resolutions)
        {
            std::string ru = r;
            for (auto& c : ru) c = (char)toupper((unsigned char)c);
            if (ru == "NOFORMAT" || r.find('+') != std::string::npos)
                nofmt = true;
        }
        std::cout << "INCLUDE_NOFORMAT=" << (nofmt ? "1" : "0") << std::endl;
    }
    else
    {
        std::cout << "RESOLUTION_FILTER=" << std::endl;
        std::cout << "INCLUDE_NOFORMAT=0" << std::endl;
    }

    std::cout << "DRY_RUN=" << (parser.HasFlag("DRY_RUN") ? "1" : "0") << std::endl;
    std::cout << "INCREMENTAL=" << (parser.HasFlag("INCREMENTAL") ? "1" : "0") << std::endl;
    std::cout << "RETRY=" << (parser.HasFlag("RETRY") ? "1" : "0") << std::endl;
}

static void OutputPackMO(const BIKArgParser& parser)
{
    std::vector<std::string> groups = parser.GetGroupFilter();
    std::vector<std::string> games = parser.GetActiveGames();

    if (!groups.empty())
        std::cout << "FILTER_GROUP=" << JoinSemicolon(groups) << std::endl;

    if (!games.empty())
        std::cout << "FILTER_GAME=" << JoinSemicolon(games) << std::endl;
}

static void OutputPackOriginal(const BIKArgParser& parser)
{
    std::vector<std::string> groups = parser.GetGroupFilter();
    std::vector<std::string> resolutions = parser.GetResolutionFilter();

    if (!groups.empty())
        std::cout << "AUDIO_GROUP=" << JoinSemicolon(groups) << std::endl;

    if (!resolutions.empty())
        std::cout << "RESOLUTION=" << resolutions[0] << std::endl;
}

static void OutputMp3ToWav(const BIKArgParser& parser)
{
    std::cout << "OVERWRITE=" << (parser.HasFlag("OVERWRITE") ? "1" : "0") << std::endl;
    std::cout << "DRY_RUN=" << (parser.HasFlag("DRY_RUN") ? "1" : "0") << std::endl;
}

static void OutputH265(const BIKArgParser& parser)
{
    std::vector<std::string> groups = parser.GetGroupFilter();
    std::string source = parser.Get("source");
    std::string output = parser.Get("output");

    if (!source.empty())
        std::cout << "SOURCE=" << source << std::endl;
    if (!output.empty())
        std::cout << "OUTPUT=" << output << std::endl;
    if (!groups.empty())
        std::cout << "GROUP_FILTER=" << JoinSemicolon(groups) << std::endl;
    std::cout << "DRY_RUN=" << (parser.HasFlag("DRY_RUN") ? "1" : "0") << std::endl;
}

static void OutputPreview(const BIKArgParser& parser)
{
    std::vector<std::string> games = parser.GetActiveGames();
    std::vector<std::string> groups = parser.GetGroupFilter();
    std::vector<std::string> resolutions = parser.GetResolutionFilter();
    std::string file = parser.Get("file");

    if (!games.empty()) std::cout << "GAME=" << games[0] << std::endl;
    if (!groups.empty()) std::cout << "GROUP=" << groups[0] << std::endl;
    if (!resolutions.empty())
    {
        std::string res = resolutions[0];
        std::string resLower = res;
        for (auto& c : resLower) c = (char)tolower((unsigned char)c);
        std::cout << "RESOLUTION=" << resLower << std::endl;
    }
    if (!file.empty()) std::cout << "FILE=" << file << std::endl;
}

static void OutputValidate(const BIKArgParser& parser)
{
    std::string path = parser.Get("path");
    if (!path.empty())
        std::cout << "SCAN_DIR=" << path << std::endl;
}

static void OutputResolution(const BIKArgParser& parser)
{
    std::string input = parser.Get("input");
    std::string output = parser.Get("output");
    std::vector<std::string> resolutions = parser.GetResolutionFilter();

    if (!input.empty()) std::cout << "INPUT=" << input << std::endl;
    if (!output.empty()) std::cout << "OUTPUT=" << output << std::endl;
    if (!resolutions.empty()) std::cout << "RESOLUTION=" << resolutions[0] << std::endl;
    std::cout << "DRY_RUN=" << (parser.HasFlag("DRY_RUN") ? "1" : "0") << std::endl;
}

static void OutputMixDiff(const BIKArgParser& parser)
{
    std::string path1 = parser.Get("path1");
    std::string path2 = parser.Get("path2");

    if (!path1.empty()) std::cout << "PATH1=" << path1 << std::endl;
    if (!path2.empty()) std::cout << "PATH2=" << path2 << std::endl;
}

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        PrintUsage();
        return 1;
    }

    BIKArgParser parser;

    std::string exeDir;
    try { exeDir = std::filesystem::path(argv[0]).parent_path().string(); }
    catch (...) { exeDir = "."; }
    std::string configPath = exeDir + "\\..\\..\\cmdparse.ini";
    parser.LoadConfig(configPath);

    parser.Parse(argc, argv);
    parser.ApplyConfigDefaults();

    if (parser.WantsHelp())
    {
        PrintUsage();
        return 0;
    }

    std::string mode = parser.GetMode();

    if (mode == "PACK_MO")
        OutputPackMO(parser);
    else if (mode == "PACK_ORIGINAL")
        OutputPackOriginal(parser);
    else if (mode == "MP3_TO_WAV")
        OutputMp3ToWav(parser);
    else if (mode == "H265")
        OutputH265(parser);
    else if (mode == "PREVIEW")
        OutputPreview(parser);
    else if (mode == "VALIDATE")
        OutputValidate(parser);
    else if (mode == "RESOLUTION")
        OutputResolution(parser);
    else if (mode == "MIX_DIFF")
        OutputMixDiff(parser);
    else
        OutputCross(parser);

    return 0;
}