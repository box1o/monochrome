-- Highest resolution, then the highest refresh rate available at that resolution.
-- Keep 1:1 scaling; built-in laptop panels are detected and placed below externals.
-- Add an entry with a specific output name only for an intentional override.
return {
    { output = "", mode = "highres", position = "auto", scale = 1 },
}
