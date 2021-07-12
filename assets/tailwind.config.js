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
        ddd: '#222433'
      },

    },
  },
  variants: {
    extend: {},
  },
  plugins: [require('tailwind-scrollbar')],
}
