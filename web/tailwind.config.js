module.exports = {
    purge:    {
        enabled:              process.env.RAILS_ENV !== "development",
        content:              [
            "./app/views/**/*.html.erb",
            "./app/views/**/**/*.html.erb",
            "./app/components/*.html.erb",
            "./app/components/**/*.html.erb",
            "./app/components/*.js",
            "./app/components/**/*.js",
            "./app/helpers/**/*.rb",
            "./app/javascript/**/*.js",
            "./app/javascript/**/**/*.js"
        ],
        preserveHtmlElements: false
    },
    theme:    {
        colors:                  {
            transparent: 'transparent',
            current:     'currentColor',
            black:       '#000',
            white:       '#fff',
            green:       {
                50:  '#F5FCF6',
                100: '#ECF8EE',
                200: '#CEEED4',
                300: '#B1E3BB',
                400: '#77CF87',
                500: '#3CBA54',
                600: '#36A74C',
                700: '#247032',
                800: '#1B5426',
                900: '#123819',
            },
            gray:        {
                50:  '#F5F5F5',
                100: '#EAEBEB',
                200: '#CBCCCE',
                300: '#ABADB0',
                400: '#6C7074',
                500: '#2D3339',
                600: '#292E33',
                700: '#1B1F22',
                800: '#14171A',
                900: '#0E0F11',
            },
            yellow:      {
                100: '#fffbf0',
                200: '#ffefc7',
                300: '#ffe5a3',
                400: '#ffd97a',
                500: '#ffcf57',
                600: '#ffbb0f',
                700: '#c28b00',
                800: '#7a5800',
                900: '#332500'
            },
            red:         {
                50:  '#FDF4F5',
                100: '#FBE9EC',
                200: '#F6C9CF',
                300: '#F0A8B2',
                400: '#E46778',
                500: '#D9263E',
                600: '#C32238',
                700: '#821725',
                800: '#62111C',
                900: '#410B13',
            },
            purple:      {
                100: '#f3f4fc',
                200: '#d0d1f1',
                300: '#acafe7',
                400: '#898ddc',
                500: '#6167d1',
                600: '#383ebd',
                700: '#292d8a',
                800: '#1b1e5b',
                900: '#0c0d27'
            }
        },
        animations:              {
            "spin": {
                from: {
                    transform: "rotate(0deg)",
                },
                to:   {
                    transform: "rotate(360deg)",
                },
            }
        },
        animationDuration:       { // defaults to these values
            "DEFAULT": "1s",
            "0s":      "0s",
            "1s":      "1s",
            "2s":      "2s",
            "3s":      "3s",
            "4s":      "4s",
            "5s":      "5s",
        },
        animationTimingFunction: {
            "DEFAULT": "ease",
            "linear":  "linear",
            "ease":    "ease",
            "ease-in": "ease-in"
        },
        animationDelay:          {
            "DEFAULT": "0s",
            "0s":      "0s",
            "1s":      "1s",
            "2s":      "2s",
            "3s":      "3s"
        },
        animationIterationCount: {
            "DEFAULT":  "infinite",
            "once":     "1",
            "infinite": "infinite",
        },
        animationDirection:      {
            "DEFAULT":           "normal",
            "normal":            "normal",
            "reverse":           "reverse",
            "alternate":         "alternate",
            "alternate-reverse": "alternate-reverse",
        },
        animationFillMode:       {
            "DEFAULT": "none"
        },
        animationPlayState:      {
            "running": "running",
            "paused":  "paused",
        },
        extend:                  {
            width:        {
                "content": "max-content",
                "128":     "32rem"
            },
            height:       {
                "content":     "max-content",
                "screen-1/2":  "50vh",
                "screen-3/4":  "75vh",
                "screen-8/10": "80vh",
                "screen-9/10": "90vh",
                "128":         "32rem"
            },
            borderRadius: {
                "xl":  "1rem",
                "2xl": "2rem"
            },
            inset:        {
                "12": "46px",
                "16": "64px",
                "24": "92px"
            },
        },
        aspectRatio:             {
            "none":   0,
            "square": [1, 1],
            "16/9":   [16, 9],
            "16/10":  [16, 10],
            "40/61":  [40, 61]
        }
    },
    variants: {
        fontWeight:  ['hover', 'focus'],
        margin:      ["responsive", "first"],
        borderWidth: ["responsive", "first"],
        aspectRatio: ["responsive"],
        textColor:   ["responsive", "hover", "focus", "group-hover"],
        display:     ["responsive", "group-hover"]
    },
    plugins:  [
        require("tailwindcss-elevation")(),
        require("tailwindcss-aspect-ratio"),
        require("tailwindcss-animations")
    ],
}