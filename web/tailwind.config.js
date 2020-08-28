module.exports = {
    purge:    {
        enabled: process.env.RAILS_ENV === "production",
        content: [
            "./app/views/**/*.html.erb",
            "./app/views/**/**/*.html.erb",
            "./app/helpers/**/*.rb",
            "./app/javascript/**/*.js",
            "./app/javascript/**/**/*.js"
        ],
    },
    theme:    {
        animations:              {
            "spin": {
                from: {
                    transform: "rotate(0deg)",
                },
                to:   {
                    transform: "rotate(360deg)",
                },
            },
            "jump": {
                "0%":   {
                    transform: "translateY(0%)",
                },
                "50%":  {
                    transform: "translateY(-100%)",
                },
                "100%": {
                    transform: "translateY(0%)",
                },
            },
        },
        animationDuration:       { // defaults to these values
            "default": "1s",
            "0s":      "0s",
            "1s":      "1s",
            "2s":      "2s",
            "3s":      "3s",
            "4s":      "4s",
            "5s":      "5s",
        },
        animationTimingFunction: {
            "default":     "ease",
            "linear":      "linear",
            "ease":        "ease",
            "ease-in":     "ease-in",
            "ease-out":    "ease-out",
            "ease-in-out": "ease-in-out",
        },
        animationDelay:          {
            "default": "0s",
            "0s":      "0s",
            "1s":      "1s",
            "2s":      "2s",
            "3s":      "3s",
            "4s":      "4s",
            "5s":      "5s",
        },
        animationIterationCount: {
            "default":  "infinite",
            "once":     "1",
            "infinite": "infinite",
        },
        animationDirection:      {
            "default":           "normal",
            "normal":            "normal",
            "reverse":           "reverse",
            "alternate":         "alternate",
            "alternate-reverse": "alternate-reverse",
        },
        animationFillMode:       {
            "default":   "none",
            "none":      "none",
            "forwards":  "forwards",
            "backwards": "backwards",
            "both":      "both",
        },
        animationPlayState:      {
            "running": "running",
            "paused":  "paused",
        },
        extend:                  {
            colors:       {
                "green": {
                    "100": "#f0fff7",
                    "200": "#9bfdca",
                    "300": "#4bfca0",
                    "400": "#05eb74",
                    "500": "#039b4d",
                    "600": "#027d3e",
                    "700": "#026431",
                    "800": "#014b25",
                    "900": "#013219"
                },
                "yellow": {
                    "100": "#fffbf0",
                    "200": "#ffefc7",
                    "300": "#ffe5a3",
                    "400": "#ffd97a",
                    "500": "#ffcf57",
                    "600": "#ffbb0f",
                    "700": "#c28b00",
                    "800": "#7a5800",
                    "900": "#332500"
                },
                "red": {
                    "100": "#fdf2f3",
                    "200": "#f4bec5",
                    "300": "#ea8a97",
                    "400": "#e15668",
                    "500": "#d9263e",
                    "600": "#ad1f32",
                    "700": "#821725",
                    "800": "#570f19",
                    "900": "#2b080c"
                },
                "purple": {
                    "100": "#f3f4fc",
                    "200": "#d0d1f1",
                    "300": "#acafe7",
                    "400": "#898ddc",
                    "500": "#6167d1",
                    "600": "#383ebd",
                    "700": "#292d8a",
                    "800": "#1b1e5b",
                    "900": "#0c0d27"
                }
            },
            width:        {
                "content": "max-content",
                "128":     "32rem"
            },
            height:       {
                "content":    "max-content",
                "screen-1/2": "50vh",
                "screen-3/4": "75vh",
                "128":        "32rem"
            },
            borderRadius: {
                "xl":  "1rem",
                "2xl": "2rem"
            }
        },
        aspectRatio:             {
            "none":   0,
            "square": [1, 1],
            "16/9":   [16, 9],
            "40/61":  [40, 61]
        }
    },
    variants: {
        margin:      ["responsive", "first"],
        aspectRatio: ["responsive"],
        textColor:   ["responsive", "hover", "focus", "group-hover"],
        display:     ["responsive", "group-hover"]
    },
    plugins:  [
        require("tailwindcss-font-inter")(),
        require("tailwindcss-elevation")(),
        require("tailwindcss-aspect-ratio"),
        require("tailwindcss-animations")
    ],
}