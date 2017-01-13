<?npl
include_once("../utils.page");

NPL.load("(gl)script/ide/System/Database/TableDatabase.lua");
local TableDatabase = commonlib.gettable("System.Database.TableDatabase");
local db = TableDatabase:new():connect("nplgitcloud/db/", function() end);

local function get_public_gists()
    local since = request:get("since");
    local page = tonumber(request:get("page"));
    local per_page = tonumber(request:get("per_page"));
    if (not page) then
        page = 1;
    end
    if (not per_page) then
        per_page = 30;
    end
    local results;
    db.Gists:find({ ["-public+update_at"] = { true, gt = since, limit = per_page, skip = (page - 1) * per_page } }, function(err, rows) results = rows; end);
    local url = get_pure_url();
    local count;
    db.Gists:count({ ["-public+update_at"] = { true, gt = since } }, function(err, rows) count = rows; end);
    local headers = {
        ["Link"] = process_pagination(url, page, per_page, count)
    };
    process_json_response(results, headers);
end

local apis = {
    {"^/gists/public$", "GET", get_public_gists}
};

function is_gists_api()
    local url = request:url():match("^[^%?]*");
    local method = request:GetMethod();
    for i = 1, #apis do
        if (url:match(apis[i][1]) and (method == apis[i][2])) then
            apis[i][3]();
            break;
        end
    end
end