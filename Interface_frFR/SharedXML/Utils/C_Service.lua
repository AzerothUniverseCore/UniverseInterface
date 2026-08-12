enum:E_SERVICE_DATA {
    "IS_GM",
    "REALM_ID",
    "IS_ENABLE_STORE",
    "ACCOUNT_ID"
}

C_ServiceMixin = {}

function C_ServiceMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()
end

function C_ServiceMixin:SERVER_SPLIT_NOTICE(_, _, _, msg)
    local messageData = C_Split(msg, ":")

    if messageData and messageData[1] == "ASMSG_SERVICE_MSG" then
        local serviceData = C_Split(messageData[2], "|")

        local isGM              = tonumber(serviceData[E_SERVICE_DATA.IS_GM])
        local realmID           = tonumber(serviceData[E_SERVICE_DATA.REALM_ID])
        local isStoreEnabled    = tonumber(serviceData[E_SERVICE_DATA.IS_ENABLE_STORE])
        local accountID         = tonumber(serviceData[E_SERVICE_DATA.ACCOUNT_ID])

        C_CacheInstance:Set("C_SERVICE_IS_GM", isGM ~= 0)
        C_CacheInstance:Set("C_SERVICE_REALM_ID", realmID)
        C_CacheInstance:Set("C_SERVICE_ENABLE_STORE", isStoreEnabled ~= 0)
        C_CacheInstance:Set("C_SERVICE_ACCOUNT_ID", accountID)

        Hook:FireEvent("SERVICE_DATA_RECEIVED", isGM, realmID, isStoreEnabled, accountID)
    end
end

---@return boolean isGM
function C_ServiceMixin:IsGM()
    return C_CacheInstance:Get("C_SERVICE_IS_GM")
end

---@return boolean isStoreEnabled
function C_ServiceMixin:IsStoreEnabled()
    return C_CacheInstance:Get("C_SERVICE_ENABLE_STORE")
end

---@return number realmID
function C_ServiceMixin:GetRealmID()
    return C_CacheInstance:Get("C_SERVICE_REALM_ID")
end

---@return number accountID
function C_ServiceMixin:GetAccountID()
    return C_CacheInstance:Get("C_SERVICE_ACCOUNT_ID")
end

function C_ServiceMixin:VARIABLES_LOADED()
    Hook:FireEvent("SERVICE_DATA_RECEIVED", self:IsGM(), self:GetRealmID(), self:IsStoreEnabled(), self:GetAccountID())
end

---@class C_ServiceMixin
C_Service = CreateFromMixins(C_ServiceMixin)
C_Service:OnLoad()

function IsGMAccount()
    return C_Service:IsGM() or false
end

function GetServerID()
    return C_Service:GetRealmID() or 0
end

function IsStoreEnable()
    return C_Service:IsStoreEnabled() or true
end

function GetAccountID()
    return C_Service:GetAccountID() or 0
end