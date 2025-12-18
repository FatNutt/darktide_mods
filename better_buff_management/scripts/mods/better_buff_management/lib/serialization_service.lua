--[[
    SerializationService

    Provides compact serialization and deserialization utilities.
    Handles encoding/decoding of data structures to/from compact string formats.

    Format: <version><field1><field2>...|<array_data>
    - Version: 1 character for format versioning
    - Fields: Single character mappings for enum-like values
    - Array data: Comma-separated values after the pipe separator
--]]

local mod = get_mod('better_buff_management')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'SerializationService'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
    INVALID_INPUT = ('%s invalid input'):format(ERROR_PREFIX),
    UNKNOWN_VERSION = ('%s unknown version "%%s"'):format(ERROR_PREFIX),
    INVALID_FIELD = ('%s invalid field "%%s" for mapping "%%s"'):format(ERROR_PREFIX),
    MISSING_SEPARATOR = ('%s missing separator'):format(ERROR_PREFIX),
}

-- ================================================
-- Fragment Dictionary for Buff Name Compression
-- ================================================
-- Order matters: longer fragments should be replaced first to avoid partial matches
-- Format: { fragment = code } where code uses special chars: @ # $ ! ~

-- Tier 1: Major prefix (biggest savings)
local FRAGMENT_TIER1 = {
    ['weapon_trait_bespoke_'] = '@',
}

-- Tier 2: Weapon types (after @ prefix)
local FRAGMENT_TIER2 = {
    ['ogryn_powermaul_slabshield_'] = '!Os',
    ['ogryn_heavystubber_'] = '!Oh',
    ['ogryn_combatblade_'] = '!Ob',
    ['ogryn_pickaxe_2h_'] = '!Op',
    ['ogryn_rippergun_'] = '!Or',
    ['ogryn_gauntlet_'] = '!Og',
    ['ogryn_thumper_'] = '!Ot',
    ['ogryn_club_'] = '!Oc',
    ['dual_stubpistols_'] = '!ds',
    ['dual_autopistols_'] = '!da',
    ['powermaul_shield_'] = '!Ps',
    ['shotpistol_shield_'] = '!Ss',
    ['thunderhammer_2h_'] = '!th',
    ['forcesword_2h_'] = '!F2',
    ['powersword_2h_'] = '!P2',
    ['chainsword_2h_'] = '!C2',
    ['powermaul_2h_'] = '!M2',
    ['heavystubber_'] = '!hs',
    ['needlepistol_'] = '!np',
    ['stubrevolver_'] = '!sr',
    ['combatsword_'] = '!cs',
    ['combatknife_'] = '!ck',
    ['forcestaff_'] = '!fs',
    ['forcesword_'] = '!fw',
    ['powersword_'] = '!ps',
    ['powermaul_'] = '!pm',
    ['chainsword_'] = '!cw',
    ['combataxe_'] = '!cx',
    ['chainaxe_'] = '!ca',
    ['plasmagun_'] = '!pl',
    ['autopistol_'] = '!ap',
    ['boltpistol_'] = '!bp',
    ['dual_shivs_'] = '!dv',
    ['laspistol_'] = '!lp',
    ['autogun_'] = '!ag',
    ['shotgun_'] = '!sg',
    ['lasgun_'] = '!lg',
    ['bolter_'] = '!bo',
    ['flamer_'] = '!fl',
    ['crowbar_'] = '!cr',
    ['saw_'] = '!sw',
}

-- Tier 3: Class/archetype prefixes
local FRAGMENT_TIER3 = {
    ['adamant_'] = '#A',
    ['veteran_'] = '#V',
    ['zealot_'] = '#Z',
    ['ogryn_'] = '#O',
    ['psyker_'] = '#P',
    ['broker_'] = '#B',
}

-- Tier 4: Common fragments (apply last, smallest codes)
local FRAGMENT_TIER4 = {
    -- Long compound fragments first
    ['_continuous_fire'] = '$cf',
    ['_multiple_hits'] = '$mh',
    ['_close_kill'] = '$ck',
    ['_elite_kills'] = '$ek',
    ['_elite_kill'] = '$eK',
    ['_weapon_special'] = '$ws',
    ['_critical_strike'] = '$cs',
    ['_increased_'] = '$i+',
    ['_increases_'] = '$i>',
    ['_reduction_'] = '$rd',
    ['_recovery_'] = '$rc',
    ['_stacking_'] = '$st',
    ['_chained_'] = '$ch',
    ['_targets_receive_'] = '$tr',
    ['_grants_'] = '$gr',
    ['_bonus_'] = '$b+',
    -- Medium fragments
    ['_weakspot_'] = '$ws',
    ['_weakspot'] = '$Ws',
    ['_toughness_'] = '$tg',
    ['_toughness'] = '$Tg',
    ['_damage_'] = '$dm',
    ['_damage'] = '$Dm',
    ['_power_'] = '$pw',
    ['_power'] = '$Pw',
    ['_rending_'] = '$rn',
    ['_rending'] = '$Rn',
    ['_attack_'] = '$at',
    ['_melee_'] = '$ml',
    ['_melee'] = '$Ml',
    ['_ranged_'] = '$rg',
    ['_ranged'] = '$Rg',
    ['_reload_'] = '$rl',
    ['_speed_'] = '$sp',
    ['_speed'] = '$Sp',
    ['_crit_'] = '$cr',
    ['_crit'] = '$Cr',
    ['_chance_'] = '$cn',
    ['_chance'] = '$Cn',
    ['_stagger_'] = '$sg',
    ['_stagger'] = '$Sg',
    ['_cleave_'] = '$cl',
    ['_cleave'] = '$Cl',
    ['_hit_'] = '$ht',
    ['_hits_'] = '$hs',
    ['_hits'] = '$Hs',
    ['_kill_'] = '$kl',
    ['_kill'] = '$Kl',
    ['_on_'] = '$o',
    -- Suffixes
    ['_parent'] = '$^',
    ['_buff'] = '$b',
    ['_effect'] = '$e',
    ['_debuff'] = '$d',
    ['_aura'] = '$a',
    ['_improved'] = '$+',
    ['_duration'] = '$u',
    ['_stacks'] = '$s',
    ['_active'] = '$v',
}

-- Build combined fragment list sorted by length (longest first) for compression
local function build_sorted_fragments()
    local all_fragments = {}

    -- Combine all tiers
    local tiers = { FRAGMENT_TIER1, FRAGMENT_TIER2, FRAGMENT_TIER3, FRAGMENT_TIER4 }
    for _, tier in ipairs(tiers) do
        for fragment, code in pairs(tier) do
            table.insert(all_fragments, { fragment = fragment, code = code })
        end
    end

    -- Sort by fragment length descending (longest first)
    table.sort(all_fragments, function(a, b)
        return #a.fragment > #b.fragment
    end)

    return all_fragments
end

-- Build reverse lookup for decompression (sorted by code length descending)
local function build_reverse_fragments(sorted_fragments)
    local reverse = {}
    for _, entry in ipairs(sorted_fragments) do
        table.insert(reverse, { code = entry.code, fragment = entry.fragment })
    end

    -- Sort by code length descending (longest first)
    table.sort(reverse, function(a, b)
        return #a.code > #b.code
    end)

    return reverse
end

-- Pre-build sorted fragment lists
local SORTED_FRAGMENTS = build_sorted_fragments()
local REVERSE_FRAGMENTS = build_reverse_fragments(SORTED_FRAGMENTS)

-- ================================================
-- Base64 Encoding/Decoding
-- ================================================
local BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

--- Encodes a string to Base64
-- @param data string: The string to encode
-- @return string: Base64 encoded string
local function base64_encode(data)
    if not data or data == '' then
        return ''
    end

    local result = {}
    local padding = ''

    -- Pad input to multiple of 3
    local remainder = #data % 3
    if remainder > 0 then
        padding = string.rep('=', 3 - remainder)
        data = data .. string.rep('\0', 3 - remainder)
    end

    -- Process 3 bytes at a time
    for i = 1, #data, 3 do
        local b1, b2, b3 = data:byte(i, i + 2)

        -- Combine 3 bytes into 24-bit number
        local n = b1 * 65536 + b2 * 256 + b3

        -- Extract 4 6-bit groups
        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64

        -- Convert to Base64 characters
        table.insert(result, BASE64_CHARS:sub(c1 + 1, c1 + 1))
        table.insert(result, BASE64_CHARS:sub(c2 + 1, c2 + 1))
        table.insert(result, BASE64_CHARS:sub(c3 + 1, c3 + 1))
        table.insert(result, BASE64_CHARS:sub(c4 + 1, c4 + 1))
    end

    -- Replace trailing characters with padding
    local encoded = table.concat(result)
    if #padding > 0 then
        encoded = encoded:sub(1, - #padding - 1) .. padding
    end

    return encoded
end

--- Decodes a Base64 string
-- @param data string: The Base64 encoded string
-- @return string: Decoded string
local function base64_decode(data)
    if not data or data == '' then
        return ''
    end

    -- Build reverse lookup table
    local decode_table = {}
    for i = 1, #BASE64_CHARS do
        decode_table[BASE64_CHARS:sub(i, i)] = i - 1
    end

    -- Remove padding and track how many bytes to remove from result
    local padding = 0
    if data:sub(-2) == '==' then
        padding = 2
        data = data:sub(1, -3) .. 'AA'
    elseif data:sub(-1) == '=' then
        padding = 1
        data = data:sub(1, -2) .. 'A'
    end

    local result = {}

    -- Process 4 characters at a time
    for i = 1, #data, 4 do
        local c1 = decode_table[data:sub(i, i)] or 0
        local c2 = decode_table[data:sub(i + 1, i + 1)] or 0
        local c3 = decode_table[data:sub(i + 2, i + 2)] or 0
        local c4 = decode_table[data:sub(i + 3, i + 3)] or 0

        -- Combine 4 6-bit values into 24-bit number
        local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4

        -- Extract 3 bytes
        local b1 = math.floor(n / 65536) % 256
        local b2 = math.floor(n / 256) % 256
        local b3 = n % 256

        table.insert(result, string.char(b1, b2, b3))
    end

    -- Remove padding bytes from result
    local decoded = table.concat(result)
    if padding > 0 then
        decoded = decoded:sub(1, -padding - 1)
    end

    return decoded
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local SerializationService = class(CLASS_NAME)

function SerializationService:init()
end

-- -------------------------------
-- ----- Compression Functions ---
-- -------------------------------

--- Compresses a single buff name using fragment substitution
-- @param buff_name string: The buff name to compress
-- @return string: The compressed buff name
function SerializationService.compress_buff_name(buff_name)
    if not buff_name or buff_name == '' then
        return ''
    end

    local result = buff_name

    -- Apply fragment substitutions (longest first)
    for _, entry in ipairs(SORTED_FRAGMENTS) do
        result = result:gsub(entry.fragment:gsub('([%.%-%+%[%]%(%)%$%^%%])', '%%%1'), entry.code)
    end

    return result
end

--- Decompresses a single buff name by reversing fragment substitution
-- @param compressed string: The compressed buff name
-- @return string: The original buff name
function SerializationService.decompress_buff_name(compressed)
    if not compressed or compressed == '' then
        return ''
    end

    local result = compressed

    -- Apply reverse substitutions (longest codes first)
    for _, entry in ipairs(REVERSE_FRAGMENTS) do
        result = result:gsub(entry.code:gsub('([%.%-%+%[%]%(%)%$%^%%])', '%%%1'), entry.fragment)
    end

    return result
end

--- Compresses an array of buff names
-- @param buff_names table: Array of buff name strings
-- @return table: Array of compressed buff names
function SerializationService.compress_buff_names(buff_names)
    if not buff_names then
        return {}
    end

    local compressed = {}
    for _, name in ipairs(buff_names) do
        table.insert(compressed, SerializationService.compress_buff_name(name))
    end
    return compressed
end

--- Decompresses an array of buff names
-- @param compressed_names table: Array of compressed buff name strings
-- @return table: Array of original buff names
function SerializationService.decompress_buff_names(compressed_names)
    if not compressed_names then
        return {}
    end

    local decompressed = {}
    for _, name in ipairs(compressed_names) do
        table.insert(decompressed, SerializationService.decompress_buff_name(name))
    end
    return decompressed
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

--- Encodes a single character using a value-to-char mapping
-- @param value string: The value to encode
-- @param mapping table: A table mapping values to single characters
-- @param default string: Default character if value not found in mapping
-- @return string: Single character representation
function SerializationService.encode_char(value, mapping, default)
    return mapping[value] or default or '?'
end

--- Decodes a single character using a char-to-value mapping
-- @param char string: The single character to decode
-- @param mapping table: A table mapping characters to values
-- @return string|nil: The decoded value, or nil if not found
function SerializationService.decode_char(char, mapping)
    return mapping[char]
end

--- Encodes an array of strings to a comma-separated string
-- @param array table: Array of strings to encode
-- @param compress boolean: Whether to compress buff names (default: false)
-- @return string: Comma-separated string
function SerializationService.encode_array(array, compress)
    if not array or #array == 0 then
        return ''
    end

    if compress then
        local compressed = SerializationService.compress_buff_names(array)
        return table.concat(compressed, ',')
    end

    return table.concat(array, ',')
end

--- Decodes a comma-separated string to an array of strings
-- @param str string: Comma-separated string to decode
-- @param decompress boolean: Whether to decompress buff names (default: false)
-- @return table: Array of strings
function SerializationService.decode_array(str, decompress)
    local array = {}
    if str and str ~= '' then
        for item in str:gmatch('[^,]+') do
            table.insert(array, item)
        end
    end

    if decompress then
        return SerializationService.decompress_buff_names(array)
    end

    return array
end

--- Serializes data using a schema definition
-- @param data table: The data to serialize
-- @param schema table: Schema defining the serialization format
--   schema = {
--       version = "1",
--       fields = {
--           { key = "direction", mapping = { horizontal = "h", vertical = "v" }, default = "h" },
--           { key = "alignment", mapping = { left = "l", right = "r" }, default = "l" },
--       },
--       array_key = "filter",  -- optional: key for array data after separator
--       compress_array = true  -- optional: whether to compress array values
--   }
-- @param use_base64 boolean: Whether to Base64 encode the result (default: true)
-- @return string: The serialized compact string (Base64 encoded if use_base64 is true)
function SerializationService.serialize(data, schema, use_base64)
    if use_base64 == nil then
        use_base64 = true
    end

    local result = schema.version or '1'

    -- Encode each field
    for _, field in ipairs(schema.fields) do
        local value = data[field.key]
        local char = SerializationService.encode_char(value, field.mapping, field.default)
        result = result .. char
    end

    -- Add separator and array data if specified
    result = result .. '|'
    if schema.array_key and data[schema.array_key] then
        result = result .. SerializationService.encode_array(data[schema.array_key], schema.compress_array)
    end

    -- Add end-of-string marker for debug purposes
    result = result .. ';'

    -- Base64 encode if requested
    if use_base64 then
        result = base64_encode(result)
    end

    return result
end

--- Deserializes a compact string using a schema definition
-- @param str string: The compact string to deserialize
-- @param schema table: Schema defining the serialization format (same as serialize)
-- @param use_base64 boolean: Whether to Base64 decode the input (default: true)
-- @return table|nil: The deserialized data, or nil on error
-- @return string|nil: Error message if deserialization failed
function SerializationService.deserialize(str, schema, use_base64)
    if use_base64 == nil then
        use_base64 = true
    end

    -- Validate input
    if type(str) ~= 'string' or str == '' then
        return nil, ERRORS.INVALID_INPUT
    end

    -- Base64 decode if requested
    if use_base64 then
        str = base64_decode(str)
    end

    local min_length = 1 + #schema.fields + 1 -- version + fields + separator
    if #str < min_length then
        return nil, ERRORS.INVALID_INPUT
    end

    -- Strip end-of-string marker if present
    if str:sub(-1) == ';' then
        str = str:sub(1, -2)
    end

    -- Parse version
    local pos = 1
    local version = str:sub(pos, pos)
    pos = pos + 1

    if version ~= (schema.version or '1') then
        return nil, ERRORS.UNKNOWN_VERSION:format(version)
    end

    local data = {}

    -- Decode each field
    for _, field in ipairs(schema.fields) do
        local char = str:sub(pos, pos)
        pos = pos + 1

        -- Build reverse mapping
        local reverse_mapping = {}
        for value, mapped_char in pairs(field.mapping) do
            reverse_mapping[mapped_char] = value
        end

        local value = SerializationService.decode_char(char, reverse_mapping)
        if not value then
            return nil, ERRORS.INVALID_FIELD:format(char, field.key)
        end

        data[field.key] = value
    end

    -- Validate separator
    local separator = str:sub(pos, pos)
    if separator ~= '|' then
        return nil, ERRORS.MISSING_SEPARATOR
    end
    pos = pos + 1

    -- Decode array data if specified
    if schema.array_key then
        local array_str = str:sub(pos)
        data[schema.array_key] = SerializationService.decode_array(array_str, schema.compress_array)
    end

    return data
end

return SerializationService
