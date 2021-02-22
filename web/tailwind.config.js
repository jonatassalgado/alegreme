const colors       = require('tailwindcss/colors')
const customColors = {
    greenHaze:       {
        DEFAULT: '#03AA54',
        '50':    '#F0FFF7',
        '100':   '#CDFEE5',
        '200':   '#87FDC0',
        '300':   '#41FB9C',
        '400':   '#05F077',
        '500':   '#03AA54',
        '600':   '#038C46',
        '700':   '#026E37',
        '800':   '#025028',
        '900':   '#013219'
    },
    lunarGreen:      {
        DEFAULT: '#454A45',
        '50':    '#B7BDB8',
        '100':   '#AAB1AB',
        '200':   '#909891',
        '300':   '#767F77',
        '400':   '#5D655E',
        '500':   '#454A45',
        '600':   '#313532',
        '700':   '#1D201E',
        '800':   '#0A0B0A',
        '900':   '#000000'
    },
    indigo:          {
        DEFAULT: '#6369D1',
        '50':    '#FFFFFF',
        '100':   '#F1F1FB',
        '200':   '#CDCFF0',
        '300':   '#AAADE6',
        '400':   '#868BDB',
        '500':   '#6369D1',
        '600':   '#3C43C5',
        '700':   '#2F359F',
        '800':   '#232878',
        '900':   '#181B50',
        body:    ''
    },
    alizarinCrimson: {
        DEFAULT: '#D7263D',
        '50':    '#FBE8EA',
        '100':   '#F7D2D7',
        '200':   '#EFA7B0',
        '300':   '#E87B89',
        '400':   '#E05063',
        '500':   '#D7263D',
        '600':   '#AC1E31',
        '700':   '#801724',
        '800':   '#550F18',
        '900':   '#2A070C'
    },
}

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
        fontFamily:  {
            display: ['Poppins', 'system-ui', 'sans-serif'],
            body:    ['Roboto', 'system-ui', 'sans-serif'],
        },
        colors:      {
            transparent: 'transparent',
            current:     'currentColor',
            black:       '#000',
            white:       '#fff',
            green:       customColors.greenHaze,
            brand:       customColors.indigo,
            gray:        colors.coolGray,
            yellow:      colors.amber,
            red:         customColors.alizarinCrimson,
            purple:      colors.purple
        },
        extend:      {
            width:        {
                "content": "max-content",
                "128":     "32rem",
                "1/7":     "14.2857143%"
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
            keyframes:    {
                show: {
                    '0%':   {opacity: 0},
                    '100%': {opacity: 1}
                },
                hide: {
                    '0%':   {opacity: 1},
                    '100%': {opacity: 0}
                }
            },
            animation:    {
                show: 'show 300ms cubic-bezier(0.4, 0.0, 0.2, 1) forwards',
                hide: 'hide 300ms cubic-bezier(0.4, 0.0, 0.2, 1) forwards'
            }
        },
        aspectRatio: {
            "none":   0,
            "square": [1, 1],
            "16/9":   [16, 9],
            "16/10":  [16, 10],
            "40/61":  [40, 61]
        }
    },
    variants: {
        fontWeight:  ['responsive', 'hover', 'focus'],
        margin:      ['responsive', 'first'],
        borderWidth: ['responsive', 'first'],
        aspectRatio: ['responsive'],
        textColor:   ['responsive', 'hover', 'focus', 'group-hover'],
        display:     ['responsive', 'group-hover'],
        zIndex:      ['responsive', 'focus-within', 'focus', 'last']
    },
    plugins:  [
        require("tailwindcss-elevation")(),
        require("tailwindcss-aspect-ratio")
    ],
}