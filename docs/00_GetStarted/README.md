# poly-dream-electric
XR 수배전 콘텐츠 제작

---

## 📚 **중요 문서 및 가이드**

이 프로젝트를 시작하기 전에 **반드시** 다음 문서들을 읽으세요!

### ⭐ **필독 문서** (작업 전 필수)

| 문서 | 설명 | 언제 읽을까? |
|------|------|-----------|
| [PowerShell_경로처리_가이드.md](PowerShell_경로처리_가이드.md) | 경로의 특수문자(대괄호, 공백, 한글) 처리 방법 | **터미널 작업 전 필수!** ⚠️ |
| [AGENTS.md](AGENTS.md) | MarsMaker MCP를 사용한 XR 콘텐츠 생성 완전 가이드 | 콘텐츠 구조를 이해하고 싶을 때 |
| [인트로_콘텐츠_구조.md](인트로_콘텐츠_구조.md) | 인트로.mars 파일의 오브젝트 구조 | 기존 콘텐츠를 분석하고 싶을 때 |

### 🚀 **빠른 시작**

```powershell
# PowerShell 프로필 로드 후 다음 명령어 사용 가능:

cdpoly              # 프로젝트 폴더로 이동
pathguide           # 경로 처리 가이드 열기 (가장 자주 필요!)
agentsguide         # MarsMaker 가이드 열기
contentguide        # 콘텐츠 구조 가이드 열기
Show-ProjectStatus  # 프로젝트 상태 확인
```

### ⚠️ **핵심 주의사항**

**경로 문제로 인한 실패를 피하려면:**

```powershell
# ❌ 하지 말 것 - 특수문자가 있는 경로를 직접 사용
cd "C:\[999999-99][폴리텍전기콘텐츠프로젝트]\..."

# ✅ 할 것 - 변수에 저장하고 사용
$projectPath = "C:\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"
$marsFile = Join-Path $projectPath "Contents\인트로.mars"
Expand-Archive -Path $marsFile -DestinationPath $extract
```

**자세한 내용은 [PowerShell_경로처리_가이드.md](PowerShell_경로처리_가이드.md)를 참고하세요!**

---

## dotnow / IL2CPP scripting guidance

When building for IL2CPP with the dotnow interpreter, certain generic and AOT restrictions apply. Follow this short checklist to avoid runtime PlatformNotSupportedException and hard-to-debug failures:

DO:
- Use List<object> instead of List<MyClass> when storing heterogeneous or user-defined items.
- Use Dictionary<string, object> instead of custom generic types (e.g., Dictionary<int, MyClass>).
- Prefer class over struct for data types that will be stored in collections.
- Use for-loops with explicit casting instead of foreach when iterating object collections.

DON'T:
- Don't use List<CustomClass> or List<CustomStruct> for collections that must be accessible at runtime by dotnow on IL2CPP.
- Don't use custom generic instantiations that the AOT toolchain cannot pre-generate (e.g., Dictionary<int, MyClass>). 
- Don't store structs in generic collections that will be accessed at runtime by the interpreter.

Why: IL2CPP does not support generating generic types at runtime (MakeGenericType) for user-defined instantiations that were not pre-generated at AOT compile time. The dotnow interpreter relies on runtime type construction in ways that can fail under these AOT limits.

Quick example (bad → good):

Bad (may fail on IL2CPP):
```csharp
// ❌ Bad - will fail on IL2CPP
private List<PathSegment> allPaths = new List<PathSegment>();
```

Good (works on IL2CPP):
```csharp
// ✅ Good - works on IL2CPP  
private List<object> allPaths = new List<object>();
PathSegment segment = (PathSegment)allPaths[i];
```

Keep this section as a quick reference for authors of `Contents/.../resource/scripts` C# files.
