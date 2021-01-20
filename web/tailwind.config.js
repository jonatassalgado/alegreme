const colors = require('tailwindcss/colors')

module.exports = {
    purge:    {
        enabled:              true,
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
        fontFamily:              {
            display: ['Mulish', 'system-ui', 'sans-serif'],
            body:    ['Mulish', 'system-ui', 'sans-serif'],
        },
        colors:                  {
            transparent: 'transparent',
            current:     'currentColor',
            black:       '#000',
            white:       '#fff',
            green:       colors.green,
            gray:        colors.coolGray,
            yellow:      colors.amber,
            red:         colors.red,
            purple:      colors.purple
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
        display:     ["responsive", "group-hover"],
        zIndex:      ['responsive', 'focus-within', 'focus', 'last']
    },
    plugins:  [
        require("tailwindcss-elevation")(),
        require("tailwindcss-aspect-ratio"),
        require("tailwindcss-animations")
    ],
}