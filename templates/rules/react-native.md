# React Native / Expo Rules

**Version Pins:** Expo SDK 52+, React Native 0.76+, TypeScript 5.4+

## Project Structure (Expo Router)

```
app/
  (tabs)/                    # Tab navigator group
    index.tsx                # Home tab
    profile.tsx              # Profile tab
    _layout.tsx              # Tab layout configuration
  (auth)/                    # Auth flow group
    login.tsx
    register.tsx
    _layout.tsx
  _layout.tsx                # Root layout (providers, fonts, splash)
  +not-found.tsx             # 404 screen
components/
  ui/                        # Reusable UI primitives
  features/                  # Feature-specific components
hooks/                       # Custom hooks
lib/                         # Utilities, API client, storage
constants/                   # Colors, spacing, config
```

## New Architecture (Fabric + TurboModules)

- Enabled by default in RN 0.76+, mandatory in RN 0.82+
- Fabric: new rendering system with synchronous layout and concurrent features
- TurboModules: lazy-loaded native modules with direct JSI access (no bridge)
- Verify all third-party libraries support New Architecture before upgrading
- Run `npx expo-doctor` to check compatibility and diagnose issues before releases

## Expo Patterns

- Use Expo SDK managed workflow with development builds for production apps
- Use Expo Router for file-based navigation (similar to Next.js App Router)
- Use `expo-*` packages over bare React Native equivalents when available
- Use EAS Build for production builds, EAS Update for OTA updates
- Configuration in `app.json` / `app.config.ts` — use config plugins for native modules

## Development Builds vs Expo Go

- **Expo Go**: Quick prototyping only — limited to Expo SDK packages, no custom native modules
- **Development builds**: Use for all real projects — supports any native library, custom native code
- Create with `npx expo run:ios` / `npx expo run:android` or `eas build --profile development`
- Development builds support `expo-dev-client` for a custom development experience

## Navigation (Expo Router)

- File-based routing in `app/` directory
- Use `_layout.tsx` for navigation configuration (Stack, Tabs, Drawer)
- Use route groups `(groupName)/` for logical grouping without URL impact
- Use `useRouter()` for programmatic navigation, `<Link>` for declarative
- Type-safe routes with `expo-router`'s typed routes

## Component Patterns

- Use `View`, `Text`, `Pressable` as base building blocks — not `div`, `span`
- Style with `StyleSheet.create()` for performance-optimized styles
- Use `FlashList` over `FlatList` for large lists (better performance)
- Platform-specific code: `Platform.select()` or `.ios.tsx` / `.android.tsx` file extensions
- Use `react-native-reanimated` for animations, `react-native-gesture-handler` for gestures

## State & Data

- Use React Query / TanStack Query for server state
- Use Zustand or Jotai for client state (lighter than Redux)
- Use `expo-secure-store` for sensitive data (tokens, credentials)
- Use `@react-native-async-storage/async-storage` for non-sensitive persistence
- Implement optimistic updates for better perceived performance

## Error Handling

```tsx
import { ErrorBoundary } from "react-error-boundary";
import * as Sentry from "@sentry/react-native";

function ErrorFallback({ error, resetErrorBoundary }: { error: Error; resetErrorBoundary: () => void }) {
  Sentry.captureException(error);
  return (
    <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <Text>Something went wrong</Text>
      <Pressable onPress={resetErrorBoundary}><Text>Try Again</Text></Pressable>
    </View>
  );
}

// Wrap feature sections, not the entire app
<ErrorBoundary FallbackComponent={ErrorFallback}><FeatureScreen /></ErrorBoundary>
```

## Performance

- Memoize expensive components with `React.memo` and callbacks with `useCallback`
- Use `useMemo` for expensive computations only (not every derived value)
- Minimize re-renders: keep state as local as possible
- Use `InteractionManager.runAfterInteractions()` for deferred work
- Profile with React DevTools and Flipper

## Platform Considerations

- Test on both iOS and Android — behavior differs
- Respect safe areas: use `SafeAreaView` or `useSafeAreaInsets()`
- Handle keyboard: `KeyboardAvoidingView` with platform-specific behavior
- Support dark mode: use `useColorScheme()` and themed styles
- Handle permissions gracefully — explain why before requesting

## Testing

```tsx
import { render, screen, userEvent } from "@testing-library/react-native";
import { ProfileScreen } from "./ProfileScreen";

test("displays user name after loading", async () => {
  render(<ProfileScreen userId="123" />);
  expect(await screen.findByText("Jane Doe")).toBeOnTheScreen();
});
```

- Use Jest + React Native Testing Library for component tests
- Use Detox or Maestro for E2E testing
- Mock native modules in `jest.setup.js`
- Test on real devices before release — simulators miss real-world issues

## DO NOT Use

- Old bridge architecture — migrate to New Architecture (Fabric + TurboModules)
- `react-native-navigation` (Wix) — use Expo Router for file-based navigation
- Expo Go for production or complex apps — use development builds
- The "eject" concept — Expo managed workflow with config plugins handles native needs
- `react-native init` for new projects — use `npx create-expo-app`
