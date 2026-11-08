def device($self): {
    id: (.ID // .HostName),
    name: (.HostName // .DNSName // "Device"),
    address: (.TailscaleIPs[0] // ""),
    os: (.OS // ""),
    online: (.Online // false),
    self: $self,
    exitNode: (.ExitNode // false),
    offersExit: (.ExitNodeOption // false)
};
{
    connected: ($state.BackendState == "Running"),
    status: ($state.BackendState // "Unavailable"),
    authUrl: ($state.AuthURL // ""),
    health: ($state.Health // []),
    devices: (if $state.BackendState == "Running" then
        [($state.Self | device(true))] +
        ([$state.Peer[]? | device(false)] | sort_by([(.online | not), (.name | ascii_downcase)]))
        else [] end),
    preferences: {
        dns: $prefs.CorpDNS,
        routes: $prefs.RouteAll,
        shields: $prefs.ShieldsUp,
        exitNode: ($prefs.ExitNodeIP // ""),
        hasExit: (($prefs.ExitNodeID // "") != "" or ($prefs.ExitNodeIP // "") != ""),
        lan: $prefs.ExitNodeAllowLANAccess
    }
}
