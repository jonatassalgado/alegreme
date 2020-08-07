module.exports = {
    purge:    {
        enabled: true,
        content: [
            "./app/views/**/*.html.erb",
            "./app/views/**/**/*.html.erb",
            "./app/helpers/**/*.rb",
            "./app/javascript/**/*.js",
            "./app/javascript/**/**/*.js"
        ],
    },
    theme:    {
        animations:              { // defaults to {}; the following are examples
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
                "chateau-green": {
                    100: "#E6F5ED",
                    200: "#C0E6D2",
                    300: "#9AD6B7",
                    400: "#4FB882",
                    500: "#03994C",
                    600: "#038A44",
                    700: "#025C2E",
                    800: "#014522",
                    900: "#012E17",
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