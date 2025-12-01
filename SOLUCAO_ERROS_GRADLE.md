# 🔧 Solução para Erros do Gradle

## ❌ Problemas Identificados

Você está enfrentando estes erros:

1. **Gradle Wrapper não encontrado:**
   ```
   Erro: Não foi possível localizar nem carregar a classe principal org.gradle.wrapper.GradleWrapperMain
   ```

2. **Espaço em disco cheio:**
   ```
   ENOSPC: no space left on device, write
   ```

3. **Java não está no PATH:**
   - O comando `java` não é reconhecido

---

## ✅ Soluções Passo a Passo

### **PASSO 1: Liberar Espaço em Disco** 🔴 URGENTE

Você precisa liberar espaço no disco antes de continuar:

1. **Limpar arquivos temporários:**
   ```powershell
   # Limpar cache do Windows
   Cleanmgr /d C:
   
   # Ou manualmente:
   # Windows + R → digite: %temp% → Delete tudo
   # Windows + R → digite: temp → Delete tudo
   ```

2. **Limpar cache do Flutter:**
   ```powershell
   flutter clean
   cd android
   if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
   if (Test-Path ".gradle") { Remove-Item -Recurse -Force ".gradle" }
   cd ..
   ```

3. **Limpar cache do Gradle (pode ser grande):**
   ```powershell
   # Caminho: C:\Users\Amanda\.gradle\caches
   # Pode ter vários GB! Delete manualmente se necessário
   Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches" -ErrorAction SilentlyContinue
   ```

4. **Verificar espaço disponível:**
   ```powershell
   Get-PSDrive C | Select-Object Used, Free
   ```

**Você precisa de pelo menos 5-10 GB livres para compilar o Android!**

---

### **PASSO 2: Verificar/Instalar Java JDK**

1. **Verificar se o Java está instalado:**
   - Abra o Android Studio
   - Vá em **File** → **Settings** → **Build, Execution, Deployment** → **Build Tools** → **Gradle**
   - Veja o caminho do JDK

2. **Ou instalar Java JDK 17:**
   - Baixe: https://adoptium.net/temurin/releases/?version=17
   - Instale e adicione ao PATH:
     - Windows + I → Sistema → Variáveis de Ambiente
     - Adicione: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\bin` ao PATH

---

### **PASSO 3: Regenerar Gradle Wrapper**

Depois de liberar espaço, execute:

```powershell
cd "C:\Users\Amanda\Desktop\TCC AMANDA\app_elpool\app_piscina"
cd android

# Copiar wrapper do Flutter SDK (se existir)
$flutterSdk = "C:\Users\Amanda\flutter\flutter"
if (Test-Path "$flutterSdk\packages\flutter_tools\gradle\wrapper\gradle-wrapper.jar") {
    Copy-Item "$flutterSdk\packages\flutter_tools\gradle\wrapper\gradle-wrapper.jar" -Destination "gradle\wrapper\gradle-wrapper.jar" -Force
}

# Ou baixar manualmente:
# 1. Acesse: https://gradle.org/releases/
# 2. Baixe Gradle 8.7
# 3. Extraia o gradle-wrapper.jar de: gradle-8.7\lib\gradle-wrapper-8.7.jar
# 4. Copie para: android\gradle\wrapper\gradle-wrapper.jar
```

**OU** use o Android Studio:

1. Abra o projeto no Android Studio
2. Vá em **File** → **Sync Project with Gradle Files**
3. O Android Studio vai baixar o wrapper automaticamente

---

### **PASSO 4: Verificar Gradle Wrapper Properties**

O arquivo `android\gradle\wrapper\gradle-wrapper.properties` já está corrigido para usar Gradle 8.7:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip
```

---

### **PASSO 5: Tentar Build Novamente**

Depois de resolver os problemas acima:

```powershell
cd "C:\Users\Amanda\Desktop\TCC AMANDA\app_elpool\app_piscina"
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🔍 Verificações Rápidas

Execute estes comandos para verificar:

```powershell
# 1. Verificar espaço em disco
Get-PSDrive C | Select-Object Used, Free

# 2. Verificar Java (deve funcionar após instalar)
java -version

# 3. Verificar Flutter
flutter doctor -v

# 4. Verificar se o wrapper existe
Test-Path "android\gradle\wrapper\gradle-wrapper.jar"
```

---

## 🆘 Se Ainda Não Funcionar

### Opção A: Usar Android Studio

1. Abra o projeto no Android Studio
2. Vá em **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
3. O Android Studio vai resolver tudo automaticamente

### Opção B: Reinstalar Gradle Wrapper

1. Abra o Android Studio
2. Vá em **File** → **Settings** → **Build, Execution, Deployment** → **Build Tools** → **Gradle**
3. Use **Gradle wrapper** e clique em **Apply**
4. Clique em **Sync Project with Gradle Files**

### Opção C: Build pelo Android Studio CLI

```powershell
cd android
.\gradlew.bat assembleRelease
```

---

## 📝 Checklist

Antes de tentar o build novamente, verifique:

- [ ] Pelo menos 5-10 GB livres no disco
- [ ] Java JDK instalado e no PATH
- [ ] Gradle wrapper.jar existe em `android\gradle\wrapper\`
- [ ] Modo de Desenvolvedor ativado no Windows
- [ ] Flutter doctor sem erros críticos

---

## 💡 Dica

Se você tiver espaço suficiente em outro disco, pode mover o cache do Gradle:

1. Criar variável de ambiente: `GRADLE_USER_HOME=D:\gradle\cache`
2. Ou mover: `C:\Users\Amanda\.gradle` para outro disco

---

**Prioridade:** Libere espaço em disco primeiro! Este é o problema mais crítico.

