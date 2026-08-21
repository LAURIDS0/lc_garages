Config.Garages = {

    -- =====================================================
    -- PUBLIC GARAGE
    -- =====================================================

    ['legion'] = {
        label = 'Legion Square Garage',
        type = 'public',

        blip = {
            enabled = true,
            sprite = 357,
            color = 3,
            scale = 0.8,
            shortRange = true
        },

        zone = {
            coords = vec3(229.24, -787.12, 31.68),
            size = vec3(43.0, 55.0, 5.0),
            rotation = 340.0
        },

        spawnPoints = {
            vec4(221.02, -806.52, 29.34, 247.95),
            vec4(224.06, -799.02, 29.31, 249.65),
            vec4(228.94, -786.61, 29.34, 248.93),
            vec4(232.46, -776.38, 29.38, 68.35),
            vec4(217.51, -771.08, 29.49, 70.23),
            vec4(211.09, -788.73, 29.56, 248.33),
        }
    },
    
    ['sandy'] = {
        label = 'Sandy Shores Garage',
        type = 'public',

        blip = {
            enabled = true,
            sprite = 357,
            color = 3,
            scale = 0.8,
            shortRange = true
        },

        zone = {
            coords = vec3(1659.61, 3812.71, 35.84),
            size = vec3(45.0, 36.0, 5.0),
            rotation = 35.0
        },

        spawnPoints = {
            vec4(1644.67, 3809.88, 33.44, 35.26),
            vec4(1647.68, 3812.44, 33.44, 34.2),
            vec4(1650.92, 3814.5, 33.44, 35.3),
            vec4(1654.34, 3816.48, 33.45, 36.98),
            vec4(1657.66, 3819.0, 33.45, 34.06),
            vec4(1661.07, 3821.27, 33.46, 34.29),
            vec4(1664.03, 3823.39, 33.46, 33.24),
            vec4(1667.12, 3826.05, 33.46, 36.61),

            vec4(1648.28, 3804.55, 33.46, 214.96),
            vec4(1651.41, 3806.7, 33.47, 213.29),
            vec4(1654.85, 3808.76, 33.48, 214.6),
            vec4(1658.39, 3810.64, 33.49, 217.24),
            vec4(1661.86, 3812.69, 33.5, 217.13),
            vec4(1664.9, 3815.41, 33.5, 217.79),
            vec4(1668.32, 3817.41, 33.51, 217.77),
            vec4(1671.57, 3819.78, 33.51, 217.66),
        }
    },


    -- =====================================================
    -- JOB GARAGE
    -- =====================================================

    ['police_ls'] = {
        label = 'LSPD Garage',
        type = 'job',

        -- Minimum grade per job.
        jobs = {
            police = 0,
            bcso = 0
        },

        blip = {
            enabled = false
        },

        zone = {
            coords = vec3(438.17, -1025.3, 31.31),
            size = vec3(17.0, 5.0, 5.0),
            rotation = 7.0
        },

        spawnPoints = {
            vec4(444.74, -1024.62, 28.97, 6.94),
            vec4(441.47, -1024.94, 28.97, 6.5),
            vec4(438.22, -1025.21, 28.97, 7.99),
            vec4(434.9, -1025.56, 28.97, 7.42),
            vec4(431.88, -1026.3, 28.97, 5.47),
        }
    },

    ['sandy_pd'] = {
        label = 'Sheriff Garage',
        type = 'job',

        -- Minimum grade per job.
        jobs = {
            police = 0,
            bcso = 0
        },

        blip = {
            enabled = false
        },

        zone = {
            coords = vec3(1846.9, 3681.73, 34.9),
            size = vec3(13.0, 10.0, 5.0),
            rotation = 300.0
        },

        spawnPoints = {
            vec4(1846.32, 3679.73, 32.51, 299.24),
            vec4(1847.84, 3676.76, 32.45, 300.47),
            vec4(1844.81, 3684.19, 32.59, 259.17),
            vec4(1848.45, 3686.31, 32.51, 256.95),
            vec4(1851.88, 3688.55, 32.45, 258.57),
            vec4(1855.62, 3690.34, 32.44, 257.3),
        }
    },

    ['sandy_ems'] = {
        label = 'EMS Garage',
        type = 'job',

        -- Minimum grade per job.
        jobs = {
            ambulance = 0,
            bcso = 0
        },

        blip = {
            enabled = false
        },

        zone = {
            coords = vec3(1767.54, 3595.86, 36.06),
            size = vec3(13.0, 15.0, 5.0),
            rotation = 300.0
        },

        spawnPoints = {
            vec4(1766.38, 3591.37, 33.62, 47.92),
            vec4(1770.0, 3593.11, 33.58, 49.72),
            vec4(1773.23, 3595.48, 33.51, 48.11),
        }
    },


    -- =====================================================
    -- PERSONAL GARAGE
    -- =====================================================

    -- ['example_personal'] = {
    --     label = 'Private Garage',
    --     type = 'personal',

    --     -- Use either citizenid or citizenids.
    --     citizenid = 'CHANGE_ME',

    --     blip = {
    --         enabled = false
    --     },

    --     zone = {
    --         coords = vec3(218.39, -817.84, 29.54),
    --         size = vec3(5.0, 5.0, 3.0),
    --         rotation = 0.0
    --     },

    --     spawnPoints = {
    --         vec4(236.0, -784.0, 30.0, 90.0),
    --         vec4(236.0, -788.0, 30.0, 90.0)
    --     }
    -- }
}
