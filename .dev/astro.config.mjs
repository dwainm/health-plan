import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  root: '.',
  srcDir: './src',
  publicDir: './public',
  outDir: './dist',
  site: 'https://health-plan.pages.dev',
  vite: {
    server: {
      allowedHosts: ['.trycloudflare.com'],
    },
  },
  integrations: [
    starlight({
      title: 'Health Plan',
      description: 'A simple, sustainable approach to nutrition and health',
      favicon: '/favicon.svg',
      customCss: ['./src/styles/custom.css'],
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/dwain/health-plan' },
      ],
      sidebar: [
        {
          label: 'Overview',
          link: '/',
        },
        {
          label: 'Planner',
          link: '/planner/',
        },
        {
          label: 'Calendar', 
          link: '/calendar/',
        },
        {
          label: 'Meals',
          items: [
            { label: 'Overview', link: '/meals/readme/' },
            { label: 'Breakfasts', collapsed: true, autogenerate: { directory: 'meals/breakfasts' } },
            { label: 'Lunches', collapsed: true, autogenerate: { directory: 'meals/lunches' } },
            { label: 'Dinners', collapsed: true, autogenerate: { directory: 'meals/dinners' } },
            { label: 'Soups', collapsed: true, autogenerate: { directory: 'meals/soups' } },
            { label: 'Special Meals', collapsed: true, autogenerate: { directory: 'meals/specialmeals' } },
            { label: 'Sides', collapsed: true, autogenerate: { directory: 'meals/sides' } },
            { label: 'Treats', collapsed: true, autogenerate: { directory: 'meals/treats' } },
          ],
        },
        {
          label: 'Bread & Baking',
          collapsed: true,
          autogenerate: { directory: 'bread' },
        },
      ],
    }),
  ],
});