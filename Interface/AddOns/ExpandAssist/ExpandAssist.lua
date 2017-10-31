OldIsRaidLeader = IsRaidLeader
function IsRaidLeader()
	return OldIsRaidLeader() or IsRaidOfficer()
end