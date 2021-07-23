module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      width: {
        "48%": "48%"
      },
      height: {
        "9/10": "calc(calc(100vh / 10) * 9)",
        "1/10": "calc(100vh / 10)"
      },
      colors: {
        mattblack: '#151515',
        revolver: '#301B4F',
        victoryblue: '#3C415C',
        coollavender: '#B4A5A5',
        aaa: '#191b28',
        bb: '#1c1e2e',
        bbb: '#1c1f2e',
        ccc: '#212534',
        ddd: '#222433',
        ebonyclay: {  
          DEFAULT: '#222831',  
          '50': '#8A99AE',  
          '100': '#7B8BA4',  
          '200': '#61728B',  
          '300': '#4C596D',  
          '400': '#37414F',  
          '500': '#222831',  
          '600': '#0D0F13',  
          '700': '#000000',  
          '800': '#000000',  
          '900': '#000000'
        },
        brightgray: {
          DEFAULT: '#393E46',
          '50': '#AAB0BA',
          '100': '#9CA3AF',
          '200': '#808998',
          '300': '#67707E',
          '400': '#505762',
          '500': '#393E46',
          '600': '#22252A',
          '700': '#0B0C0E',
          '800': '#000000',
          '900': '#000000'
        },
        bondiblue: {
          DEFAULT: '#00ADB5',
          '50': '#9CFBFF',
          '100': '#82F9FF',
          '200': '#4FF7FF',
          '300': '#1CF5FF',
          '400': '#00DEE8',
          '500': '#00ADB5',
          '600': '#007C82',
          '700': '#004C4F',
          '800': '#001B1C',
          '900': '#000000'
        },
        gallery: {
          DEFAULT: '#EEEEEE',
          '50': '#FFFFFF',
          '100': '#FFFFFF',
          '200': '#FFFFFF',
          '300': '#FFFFFF',
          '400': '#FFFFFF',
          '500': '#EEEEEE',
          '600': '#D4D4D4',
          '700': '#BBBBBB',
          '800': '#A2A2A2',
          '900': '#888888'
        },
      },

    },
  },
  variants: {
    extend: {},
  },
  plugins: [require('tailwind-scrollbar')],
}
