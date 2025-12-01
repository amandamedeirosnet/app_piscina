# 📱 Como Rodar o App Localmente

## ❌ Problema Identificado

Você não consegue rodar o app porque **não há dispositivo Android conectado ou emulador rodando**.

## ✅ Solução: Usar Emulador Android

Você tem um emulador disponível: **Medium_Phone_API_36.1**

---

## 🚀 Passo a Passo para Rodar o App

### **Opção 1: Rodar no Emulador (Recomendado)**

#### Passo 1: Iniciar o Emulador

```powershell
cd "C:\Users\Amanda\Desktop\TCC AMANDA\app_elpool\app_piscina"
flutter emulators --launch Medium_Phone_API_36.1
```

**OU** inicie pelo Android Studio:
1. Abra o Android Studio
2. Clique em **Device Manager** (ícone de celular na barra lateral)
3. Encontre **Medium Phone API 36.1**
4. Clique no botão ▶️ (Play) para iniciar

#### Passo 2: Aguardar o Emulador Iniciar

- O emulador pode levar 1-2 minutos para iniciar completamente
- Aguarde até ver a tela inicial do Android

#### Passo 3: Verificar se o Emulador Está Conectado

```powershell
flutter devices
```

Você deve ver algo como:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 14 (API 36)
```

#### Passo 4: Rodar o App

```powershell
flutter run
```

**OU** especificar o emulador:
```powershell
flutter run -d emulator-5554
```

---

### **Opção 2: Rodar em Dispositivo Físico**

#### Passo 1: Preparar o Celular

1. **Ativar Modo de Desenvolvedor:**
   - Vá em **Configurações** → **Sobre o telefone**
   - Toque 7 vezes em **"Número da compilação"** ou **"Versão do Android"**
   - Aparecerá a mensagem "Você é um desenvolvedor"

2. **Ativar Depuração USB:**
   - Vá em **Configurações** → **Opções do desenvolvedor**
   - Ative **"Depuração USB"**
   - Se aparecer um aviso, confirme

3. **Conectar via USB:**
   - Conecte o celular ao computador via cabo USB
   - Se aparecer no celular: "Permitir depuração USB?", marque **"Sempre permitir deste computador"** e toque em **OK**

#### Passo 2: Verificar Conexão

```powershell
flutter devices
```

Você deve ver seu dispositivo Android listado.

#### Passo 3: Rodar o App

```powershell
flutter run
```

---

### **Opção 3: Rodar no Chrome (Web) - Para Testes Rápidos**

Se você só quer testar a interface (sem Bluetooth):

```powershell
flutter run -d chrome
```

⚠️ **Nota:** Bluetooth não funciona no navegador, então funcionalidades que dependem do ESP32 não vão funcionar.

---

## 🔧 Solução de Problemas

### Erro: "No devices found"

**Solução:**
1. Verifique se o emulador está rodando: `flutter devices`
2. Se não aparecer, reinicie o emulador
3. Ou conecte um dispositivo físico

### Erro: "Waiting for another flutter command to release the startup lock"

**Solução:**
```powershell
# Matar processos do Flutter
taskkill /F /IM flutter.exe
taskkill /F /IM dart.exe

# Ou reinicie o terminal
```

### Erro: "Gradle build failed"

**Solução:**
```powershell
flutter clean
flutter pub get
cd android
.\gradlew.bat clean
cd ..
flutter run
```

### Emulador Muito Lento

**Solução:**
1. No Android Studio → Device Manager
2. Edite o emulador (ícone de lápis)
3. Aumente a RAM e CPU:
   - RAM: 2048 MB ou mais
   - VM heap: 512 MB
   - Graphics: Hardware - GLES 2.0

### App Não Aparece no Emulador

**Solução:**
1. Verifique se há erros no terminal
2. Verifique os logs: `flutter logs`
3. Tente rodar em modo debug primeiro: `flutter run --debug`

---

## 📋 Comandos Úteis

```powershell
# Ver dispositivos disponíveis
flutter devices

# Ver emuladores disponíveis
flutter emulators

# Iniciar emulador específico
flutter emulators --launch Medium_Phone_API_36.1

# Rodar app (modo debug - mais rápido)
flutter run

# Rodar app (modo release - mais lento mas otimizado)
flutter run --release

# Rodar em dispositivo específico
flutter run -d <device-id>

# Ver logs em tempo real
flutter logs

# Hot reload (pressione 'r' no terminal quando o app estiver rodando)
# Hot restart (pressione 'R' no terminal)
# Parar o app (pressione 'q' no terminal)
```

---

## 🎯 Resumo Rápido

**Para rodar o app AGORA:**

1. ```powershell
   flutter emulators --launch Medium_Phone_API_36.1
   ```

2. Aguarde o emulador iniciar (1-2 minutos)

3. ```powershell
   flutter run
   ```

4. O app vai compilar e instalar automaticamente no emulador!

---

## 💡 Dica

Se o emulador for muito lento, considere usar um dispositivo físico Android via USB. É muito mais rápido para desenvolvimento!

