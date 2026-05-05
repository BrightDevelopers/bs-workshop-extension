# Product Requirements Document: BrightSign Extension Workshop

## 1. Overview

A hands-on workshop guiding developers through creating their first BrightSign extension in Java, from local setup through production deployment.

**Target Audience:** Java developers new to BrightSign
**Duration:** Full day (6-8 hours)
**Technology:** Java 8+, Maven/Gradle, BrightSign JVM

---

## 2. Prerequisites

### Software
- Java Development Kit (JDK) 11+
- Apache Maven 3.6+ or Gradle 6.0+
- Git
- IDE (IntelliJ IDEA, Eclipse, or VS Code with Java extensions)
- Web browser

### Hardware
- BrightSign player (LS423, LS424, XD1034, or later with extension support)
- Development computer (Windows, macOS, or Linux)
- Network connectivity between computer and player

### Skills Required
- Java programming experience
- Command-line familiarity
- Basic understanding of HTTP/REST APIs

---

## 3. Computer Configuration

### JDK Setup
- Install JDK 11+
- Configure JAVA_HOME environment variable
- Verify installation with `java -version`

### Build Tool Setup
- Install Maven 3.6+ or Gradle 6.0+
- Verify installation

### Git Configuration
- Install Git and configure user information

### IDE Setup
- Install preferred IDE with Maven/Gradle support
- Configure JDK path

### Network Setup
- Determine BrightSign player IP address
- Verify network connectivity via ping
- Default API port: 8008

---

## 4. BrightSign Player Configuration

### Initial Setup
- Power on and boot player
- Access web interface at `http://<player_ip>`
- Configure network (static or DHCP)

### Development Mode
- Enable Local Extensions
- Enable Insecure Content Loading
- For development/testing only

### Production/Secure Mode
- Enable Secure Boot
- Enable Content Signature Verification
- Set Extension Loading Mode to "Signed Only"
- Disable Insecure Content Loading

### Storage
- Ensure `/tmp` directory exists and is writable
- Create extension output directory if needed

---

## 5. Required Cables and Connectivity

| Component | Purpose |
|-----------|---------|
| Power cable | Power the player |
| Ethernet cable (Cat5e+) | Network connectivity (recommended) |
| HDMI cable | Display output (optional) |
| USB cable | Alternative direct connection |

**Network Options:**
- Ethernet (recommended, most stable)
- Wi-Fi (less stable)
- USB direct connection (fallback)

---

## 6. Extension Development Requirements

### Architecture
Extensions must:
- Run on BrightSign JVM
- Have a defined entry point (main class in manifest)
- Support lifecycle hooks (startup, shutdown)
- Access player APIs via JVM

### Project Structure
- Maven/Gradle project with standard Java structure
- `src/main/java/` for source code
- `src/main/resources/manifest.json` for metadata
- `pom.xml` or `build.gradle` for dependencies

### Essential Files
- `pom.xml` or `build.gradle` - build configuration
- `manifest.json` - extension metadata with mainClass reference
- Main entry class with startup logic

### Development Workflow
1. Create Maven/Gradle project
2. Implement extension classes
3. Build JAR with Maven/Gradle
4. Package into ZIP with manifest.json
5. Deploy to player
6. Test and iterate

---

## 7. Available Extension Templates and Samples

Reference repositories for learning:
- **Extension Template:** https://github.com/brightsign/extension-template
- **Image Stream Server:** https://github.com/brightsign/bs-image-stream-server
- **NPU Gaze Extension:** https://github.com/brightsign/brightsign-npu-gaze-extension

These provide examples of:
- Project structure and build configuration
- HTTP server implementation
- Graphics rendering
- File I/O patterns
- Real-time processing

---

## 8. Extension Deployment Process

### Build for Deployment
- Run Maven/Gradle build: `mvn clean package`
- Verify JAR created with all dependencies (shaded/fat JAR)
- JAR must be complete with no external dependencies

### Create ZIP Package
- Create directory containing:
  - Shaded JAR
  - manifest.json
  - Any additional configuration files
- Package into ZIP archive
- Root of ZIP must contain `manifest.json`

### ZIP Requirements
- Maximum size: 100MB
- manifest.json must have correct `mainClass` reference
- JAR must include all dependencies (shaded)
- File permissions preserved

---

## 9. Unzipping Extension on Player

### Via Web Interface
- Access BrightSign web interface
- Navigate to Extensions section
- Upload ZIP file
- System extracts to `/extensions/my-extension/`

### Via SSH/Command Line
- SSH into player
- Navigate to `/extensions` directory
- Unzip file: `unzip my-extension.zip -d ./my-extension`
- Set permissions: `chmod -R 755 /extensions/my-extension`

---

## 10. Installing and Starting Extension

### Installation
- Via web interface: Upload and confirm installation
- System registers extension and grants permissions

### Starting Extension
- Via web interface: Extensions > [Extension Name] > Start
- Via REST API: `POST http://<player_ip>:8008/api/extensions/my-extension/start`
- Status should show "Running"

---

## 11. Stopping Extension

### Normal Stop
- Via web interface: Extensions > [Extension Name] > Stop
- Via REST API: `POST http://<player_ip>:8008/api/extensions/my-extension/stop`
- Status changes to "Stopped"

### Emergency Stop
- Restart player if extension unresponsive
- Disable autostart if needed

---

## 12. Redeploying Extensions

Standard update workflow:

```
1. Stop current extension
   ↓
2. Build new version (mvn clean package)
   ↓
3. Create updated ZIP
   ↓
4. Upload new ZIP to player
   ↓
5. Install/register new version
   ↓
6. Start new extension
```

### Rollback
If issues occur, restore previous version from backup and restart.

---

## 13. Signing Extensions for Production

### Prerequisites
- Valid BrightSign signing certificate
- Private key for signing
- BrightSign signing tool

### Process
1. Build production JAR
2. Package in signing format
3. Sign with certificate and private key
4. Verify signature before deployment

### Deployment to Secure Players
- Player must be in secure/production mode
- Player automatically verifies signature before installation
- Only signed extensions run on secure players

### Certificate Management
- Store private keys securely (never in version control)
- Use environment variables for key paths in CI/CD
- Rotate certificates per BrightSign security guidelines

---

## 14. Security Profile: Development vs Production

### Development/Insecure Environment
**Use for:** Local development and testing only

| Feature | Status |
|---------|--------|
| Local Extensions | Enabled |
| Unsigned Content | Allowed |
| Remote Debugging | Enabled |
| File System Access | Unrestricted |
| Extension Signing | Not required |

**Configuration:** Enable all developer options in player settings

**Security Risks:** No verification of extension source; suitable only for isolated testing

### Production/Secure Environment
**Use for:** Field deployments and public installations

| Feature | Status |
|---------|--------|
| Local Extensions | Disabled |
| Unsigned Content | Rejected |
| Remote Debugging | Disabled |
| File System Access | Restricted to designated directories |
| Extension Signing | Required |
| Secure Boot | Enabled |

**Configuration:** Enable all security options in player settings

**File Restrictions:** Extensions can write to `/tmp` and own directory only

**Network Restrictions:** HTTPS required for external APIs; certificate pinning recommended

### Transition Checklist
- ✓ No hardcoded credentials in code
- ✓ Debug logging disabled
- ✓ All external communication uses HTTPS
- ✓ Extension properly signed with valid certificate
- ✓ Tested on secure player configuration
- ✓ File I/O uses only permitted directories

---

## 15. Workshop End Product Specification

### Deliverable
A working Java extension that:
- Renders animated graphics programmatically
- Writes rendered frames to `/tmp/output.jpg` at 30 FPS
- Serves image via HTTP endpoint: `http://<player_ip>:8080/image.jpg`
- Returns JPEG format with proper content-type headers
- Runs continuously with minimal CPU overhead

### Technical Requirements
- **Frame Rate:** 30 FPS (33.3ms per frame)
- **Output Format:** JPEG image
- **Output Location:** `/tmp/output.jpg`
- **HTTP Endpoint:** Port 8080, path `/image.jpg`
- **Content Type:** image/jpeg
- **Image Quality:** Optimized for streaming (quality 0.7-0.8 range)

### Architecture Components
- Animation Engine: Calculates frame state and animation parameters
- Rendering Engine: Draws graphics and converts to JPEG
- File System Writer: Writes JPEG to `/tmp/output.jpg`
- HTTP Server: Serves current image via HTTP endpoint

### Performance Optimization Considerations
- Resolution: 1920x1080 (full HD) recommended
- JPEG quality: 0.7-0.8 for quality/size balance
- File I/O: Write to `/tmp` (RAM disk) for speed
- Rendering: Use efficient graphics APIs, avoid complex filters
- Threading: Dedicated thread for animation loop; thread pool for HTTP

### Testing Requirements
- **Local Test:** Build and run JAR locally; verify animation in browser
- **On-Player Test:** Deploy to BrightSign; verify HTTP endpoint serves animation
- **Performance Verification:** Monitor file modification rate and CPU usage

---

## 16. Reference Materials

- **BrightSign Extension Docs:** https://github.com/brightsign/extension-template
- **Image Server Example:** https://github.com/brightsign/bs-image-stream-server
- **Advanced Example:** https://github.com/brightsign/brightsign-npu-gaze-extension

---

## Document Version and Maintenance

**Version:** 1.0
**Last Updated:** 2026-03-20
**Maintained By:** BrightSign Workshop Team
