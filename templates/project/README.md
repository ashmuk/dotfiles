# <your-project-name>

<to-be-filled>

## Project Status

This below is still the sample for start and expected to be revised once overview is clarified.

**Current Stage**: Stage <x-y> - <short-description>

**Existing Site**: <to-be-filled> if present

**Target Site**: Production at [https://xxx.yyy.com](https://xxx.yyy.com) (<tech-stack-short-description>)

## Roadmap

1. ✅ **Analyze the existing assets and structure** — <current-status>
   - ✓ <to-be-filled>

2. ✅ **Collect all existing assets** — <current-status>
   - ✓ <to-be-filled>

3. ✅ **Define new concept and policy** — <current-status>
   - ✓ <to-be-filled>

4. ✅ **Define technology stack** — <current-status>
   - ✓ <to-be-filled>

5. 🔄 **Implement prototype of new site on AWS as MVP** — <current-status>
   - **5a** ✅ Local MVP built and functional
   - **5b** ✅ AWS deployment complete (live at https://xxx.yyy.com)
   - **5c** ✅ Design refinement complete
     - ✓ <to-be-filled>
   - **5d** 🔄 CI/CD Pipeline Security ongoing ← _Current_
     - ✓ PR checks workflow created
     - ✓ PR template created
     - ✓ Branch protection documentation
     - ⏳ Testing PR workflow
     - ⏳ Branch protection rules setup

6. ⏳ **Enhance and finalize new portfolio site and release** — PENDING
   - Production deployment to AWS
   - ✓ <to-be-filled>

7. ⏳ **Upgrade design with advanced features** — PENDING
   - Contact form, analytics, enhanced interactions

## Tech Stack

Finalized in Stage 4 via Architecture Decision Records (ADRs):

### Frontend
- **Framework**: Astro 5.x — Content-focused SSG with excellent performance
- **Styling**: Tailwind CSS 4.x — Utility-first CSS with modern features
- **Language**: TypeScript — Type safety for scripts and components
- **Content**: Content Collections with Zod schema validation
- **Images**: Astro Image (build-time optimization) generating WebP + JPEG

### Infrastructure (Planned for Stage 5b)
- **Hosting**: AWS S3 (static files) + CloudFront (CDN)
- **SSL**: AWS Certificate Manager (ACM) - free certificates
- **DNS**: Route53 - AWS-integrated DNS management
- **CI/CD**: GitHub Actions - automated build and deploy
- **Monitoring**: CloudWatch (metrics, alarms, logs)

### Development
- **Package Manager**: npm
- **Version Control**: Git + GitHub (private repository)
- **DevContainer**: Docker-based development environment
- **Branch Strategy**: Git Flow (main, develop, feature/*)

## Repository Structure

```text
<project-root>/
├── .claude/                    # Claude Code configuration
├── .devcontainer/              # Docker DevContainer setup
├── frontend/                   # Astro 5.x application (Stage 5a)
│   ├── src/
│   │   ├── pages/              # Route pages (index, galleries, about)
│   │   ├── components/         # Reusable components (Navigation, Footer, Lightbox)
│   │   ├── layouts/            # Layout templates (BaseLayout)
│   │   ├── content/            # Content Collections (20 galleries)
│   │   ├── styles/             # Global CSS + design tokens
│   │   └── utils/              # Helper functions
│   ├── public/
│   │   └── images/             # Optimized images (781 files)
│   ├── package.json            # npm dependencies
│   ├── astro.config.mjs        # Astro configuration
│   └── tailwind.config.mjs     # Tailwind CSS config
├── assets_legacy/              # Stage 2: Original downloaded assets (if present)
├── scripts/                    # Migration and utility scripts
├── docs/                       # Project documentation
│   ├── analytics/              # Stage 1: Analysis outputs (site structure, quality reports)
│   ├── concept/                # Stage 3: Design system, brand guidelines, wireframes
│   └── decisions/              # Stage 4: ADRs and architecture diagrams
├── PLAN.md                     # Technology roadmap
├── README.md                   # This file
└── CLAUDE.md                   # AI assistant guidelines
```

## Development

### Prerequisites

- **OS**: macOS Sequoia 15.7.1
- **Languages**: TypeScript/JavaScript (Astro), Python (migration scripts)
- **Runtime**: Node.js 20+
- **Cloud**: AWS account with S3, CloudFront, Route53 access (for Stage 5b)
- **Version Control**: Git + GitHub (private repository)

### Local Development (Stage 5c - Current)

**Running the Development Server:**
```bash
cd frontend
npm install        # First time only
npm run dev        # Start dev server at http://localhost:4321
```

**Building for Production:**
```bash
cd frontend
npm run build      # Generates static site in dist/
npm run preview    # Preview production build locally
```

**Testing Mobile View:**
- Open dev server in browser
- Press F12 → Toggle device toolbar (Ctrl+Shift+M)
- Test at breakpoints: 375px (mobile), 768px (tablet), 1024px+ (desktop)

### Project Statistics

- **Pages**: 23 (1 homepage, 20 galleries, 1 about, 1 galleries index)
- **Images**: 781 total (organized across 20 galleries)
- **Galleries**: 20 collections across 6 categories
- **Build Time**: ~2-3 seconds for full static site generation
- **Bundle Size**: Optimized with Astro's zero-JS by default

### Version Control

- **Main branch**: `main` (protected, production-ready)
- **Development branch**: `develop` (current - integration branch)
- **Feature branches**: `feature/*` (Git Flow branching strategy)
- **Commit format**: Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `style:`, etc.)
- **Tagging**: `v{X}.{yy}` where X = stage number, yy = fixes/patches
- **Current Branch**: `develop` (18 commits ahead of origin)

### Pull Request Workflow

Starting from Stage 5d, all changes to `main` branch must go through pull requests with automated quality checks.

**Creating a Pull Request:**

1. Create a feature branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "feat(scope): description"
   git push -u origin feature/your-feature-name
   ```

3. Create a PR on GitHub:
   - Go to repository → **Pull requests** → **New pull request**
   - Base: `main` or `develop`, Compare: `feature/your-feature-name`
   - Fill in the PR template with details
   - Submit the PR

4. Wait for automated checks to complete:
   - ✅ Build Validation - Ensures Astro site builds successfully
   - ✅ Lighthouse CI - Validates performance scores (Performance > 90, Accessibility > 90)
   - ✅ TypeScript Type Check - Ensures no type errors
   - ✅ Lint Check - Validates code style (if configured)

5. Address any failed checks:
   - Review the workflow logs on GitHub Actions tab
   - Fix issues locally and push new commits
   - Checks will automatically re-run

6. Request review (if required) and merge:
   - Once all checks pass, the PR is ready for review
   - After approval, use **Squash and merge** for feature branches
   - Delete the branch after merging

**Branch Protection Rules:**

The `main` branch is protected using **local git hooks** (free alternative):
- Direct pushes are blocked by pre-push hook
- Pull requests required for all merges
- Automated PR checks run on all pull requests
- Manual discipline required for reviews and status checks

**Setup (Required for all developers)**:
```bash
./scripts/boilerplate/setup-git-hooks.sh
```

**Note**: GitHub branch protection requires GitHub Pro/Team/Enterprise for private repos. We use local git hooks as a free alternative. For detailed setup and comparison, see:
- [Git Hooks Setup Guide](docs/GIT_HOOKS_SETUP.md) - Free alternative (current)
- [Branch Protection Setup Guide](docs/BRANCH_PROTECTION_SETUP.md) - Paid alternative (if upgrading)

**Testing Locally Before PR:**

Always test your changes locally before creating a PR:
```bash
cd frontend
npm run build          # Verify build succeeds
npx astro check        # Verify no TypeScript errors
npm run preview        # Test production build locally
```

## Guidelines

### Key Principles

- Maintain existing site operational during migration (if present)
- Preserve image quality during asset collection
- Maintain or improve SEO rankings
- No production deployments until Stage 5

### Review Policy

- All AI-generated code requires maintainer review
- Lint and format checks (Prettier, ESLint) before commit
- Sensitive keys excluded from commits (`.env`, `config.json`)

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - AI assistant guidelines and project policy
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Comprehensive project context, architecture decisions, and full development guidelines

## License

Private project - All rights reserved
