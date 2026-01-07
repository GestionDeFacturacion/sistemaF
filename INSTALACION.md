# 📋 Guía de Instalación - FacturadorPro5

> **Importante:** Esta guía documenta la instalación completa del sistema de facturación electrónica FacturadorPro5 en entorno Windows con Laragon.

---

## 📌 Tabla de Contenidos

1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Instalación de Laragon](#instalación-de-laragon)
3. [Configuración de MySQL 5.7](#configuración-de-mysql-57)
4. [Configuración del Proyecto](#configuración-del-proyecto)
5. [Migraciones y Base de Datos](#migraciones-y-base-de-datos)
6. [Configuración de Módulos](#configuración-de-módulos)
7. [Configuración SUNAT](#configuración-sunat)
8. [Creación de Clientes/Tenants](#creación-de-clientestenants)
9. [Solución de Problemas](#solución-de-problemas)

---

## 🖥️ Requisitos del Sistema

### Software Necesario

| Software | Versión | Notas |
|----------|---------|-------|
| **Windows** | 10/11 | Sistema operativo |
| **Laragon** | Última versión | Entorno de desarrollo local |
| **MySQL** | **5.7.44** | ⚠️ CRÍTICO: Descargar manualmente |
| **PHP** | **7.4.x** | Descargar e instalar en Laragon |
| **Node.js** | **16.x** | Descargar e instalar en Laragon |
| **Apache** | 2.4+ | Incluido en Laragon |
| **Composer** | 2.0+ | Incluido en Laragon |

> ⚠️ **IMPORTANTE:** 
> - MySQL **DEBE** ser 5.7 (no 8.0+) para evitar errores de migración
> - PHP 7.4 y Node 16 son las versiones **requeridas** por el sistema
> - MySQL, PHP y Node **NO** vienen en Laragon y deben descargarse manualmente

---

## 🚀 Instalación de Laragon

### Paso 1: Descargar Laragon

1. Visita: [https://laragon.org/download/](https://laragon.org/download/)
2. Descarga la versión **Full**
3. Ejecuta el instalador como **Administrador**

### Paso 2: Instalación

1. Acepta la ruta predeterminada: `C:\laragon`
2. Completa la instalación
3. **Inicia Laragon** por primera vez

### Paso 3: Instalar PHP 7.4

**PHP NO viene incluido, debes descargarlo:**

1. **Descarga PHP 7.4:**
   - Ve a: [https://windows.php.net/downloads/releases/archives/](https://windows.php.net/downloads/releases/archives/)
   - Busca: `php-7.4.33-Win32-vc15-x64.zip` (Thread Safe)
   - Descarga el archivo

2. **Instalar en Laragon:**
   - Descomprime el archivo
   - Copia la carpeta a: `C:\laragon\bin\php\`
   - Renombra a: `php-7.4.33`

3. **Seleccionar versión:**
   - Click derecho en Laragon → **PHP → Versión → php-7.4.33**

### Paso 4: Instalar Node.js 16

**Node.js tampoco viene incluido:**

1. **Descarga Node 16:**
   - Ve a: [https://nodejs.org/en/download/releases/](https://nodejs.org/en/download/releases/)
   - Busca: `v16.20.2` (última de la rama 16.x)
   - Descarga: `node-v16.20.2-win-x64.zip`

2. **Instalar en Laragon:**
   - Descomprime el archivo
   - Copia la carpeta a: `C:\laragon\bin\nodejs\`
   - Renombra a: `node-v16`

3. **Verificar instalación:**
   - Abre Terminal de Laragon
   - Ejecuta: `node -v` (debe mostrar v16.x.x)
   - Ejecuta: `npm -v`

---

## 🗄️ Configuración de MySQL 5.7

### ¿Por qué MySQL 5.7?

El sistema usa migraciones diseñadas para MySQL 5.7. Usar MySQL 8.0+ generará errores como:
```
SQLSTATE[HY000]: General error: 6125 Failed to add the foreign key constraint
```

### Paso 1: Descargar MySQL 5.7

1. **Ve a:** [MySQL Downloads Archive](https://downloads.mysql.com/archives/community/)
2. **Selecciona:**
   - Product Version: `5.7.44` (última de 5.7)
   - Operating System: `Windows (x86, 64-bit)`
   - Download: `ZIP Archive`
3. **Descarga** el archivo `.zip`

### Paso 2: Instalar en Laragon

1. **Descomprime** el archivo descargado
2. **Copia** la carpeta completa a: `D:\laragon\bin\mysql\`
3. **Renombra** la carpeta a: `mysql-5.7.44-winx64`

**Ruta final:** `D:\laragon\bin\mysql\mysql-5.7.44-winx64\`

### Paso 3: Seleccionar MySQL 5.7 en Laragon

**ANTES de iniciar MySQL:**

1. **Click derecho** en icono de Laragon
2. **MySQL → Versión → mysql-5.7.44-winx64**
3. **Verifica** que esté seleccionado (✓)

### Paso 4: Inicializar MySQL 5.7

**Abre Terminal de Laragon** (Click derecho → Terminal):

```powershell
# Inicializar base de datos
cd D:\laragon\bin\mysql\mysql-5.7.44-winx64\bin
.\mysqld --initialize-insecure --basedir=D:\laragon\bin\mysql\mysql-5.7.44-winx64 --datadir=D:\laragon\data\mysql --log_syslog=0
```

> 📝 **Nota:** Esto crea la carpeta de datos y el usuario root sin contraseña

### Paso 5: Iniciar Servicios

1. **En Laragon**, click **"Start All"**
2. **Espera** a que aparezca icono verde
3. **Verifica** que puerto 3306 esté activo

---

## ⚙️ Configuración del Proyecto

### Paso 1: Clonar/Descargar Proyecto

```powershell
# Si usas Git
cd D:\laragon\www
git clone [URL_DEL_REPOSITORIO] facturadorpro5

# O simplemente copia la carpeta del proyecto a D:\laragon\www\facturadorpro5
```

### Paso 2: Configurar `.env`

**Copia el archivo de ejemplo:**

```powershell
cd D:\laragon\www\facturadorpro5
copy .env.example .env
```

**Edita `.env` con estos valores:**

```env
APP_NAME="FacturadorPro5"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://facturadorpro5.test
APP_URL_BASE=facturadorpro5.test

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tenancy
DB_USERNAME=root
DB_PASSWORD=

# API Peru Dev (para consultas RUC/DNI)
API_SERVICE_URL=https://apiperu.dev/api
API_SERVICE_TOKEN=TU_TOKEN_AQUI
```

### Paso 3: Instalar Dependencias

```powershell
# Instalar dependencias PHP
composer install
```

> ⚠️ **IMPORTANTE:** 
> - **NO ejecutes** `php artisan key:generate` - La key ya existe en `.env`
> - **NO ejecutes** `npm install` ni `npm run dev` - Los assets ya están compilados

---

## 💾 Migraciones y Base de Datos

### Paso 1: Crear Base de Datos

**En Terminal de Laragon:**

```powershell
# Usar ruta completa de MySQL
D:\laragon\bin\mysql\mysql-5.7.44-winx64\bin\mysql.exe -u root -e "CREATE DATABASE tenancy;"
```

### Paso 2: Ejecutar Migraciones del Sistema

```powershell
cd D:\laragon\www\facturadorpro5

# Migrar base de datos del sistema (admin)
php artisan migrate --database=system

# Ejecutar seeders (datos iniciales)
php artisan db:seed --database=system
```

### Paso 3: Configurar Token API Peru Dev

**⚠️ IMPORTANTE:** El token **SOLO** funciona si está en la base de datos, **NO** en `.env`

Abre **HeidiSQL** (Laragon → Database → HeidiSQL):

```sql
-- Actualizar token en la configuración del sistema
UPDATE tenancy.configurations 
SET token_apiruc = 'TU_TOKEN_AQUI' 
WHERE id = 1;
```

---

## 🎛️ Configuración de Módulos

### Módulos del Sistema

**✅ Por defecto, TODOS los módulos ya están activados** después de crear el tenant.

Si necesitas activar módulos adicionales manualmente:

```sql
-- Ver módulos disponibles
SELECT id, value, description FROM tenancy.modules ORDER BY id;

-- Activar todos los módulos para un cliente
INSERT INTO tenancy_[NOMBRE_CLIENTE].module_level_client (client_id, module_id, module_level_id)
SELECT 1, module_id, id
FROM tenancy.module_levels;
```

### Módulos Principales Disponibles

| ID | Módulo | Descripción |
|----|--------|-------------|
| 1 | documents | Ventas/Comprobantes |
| 2 | purchases | Compras |
| 3 | advanced | Documentos Avanzados (Guías) |
| 6 | pos | Punto de Venta |
| 8 | inventory | Inventario |
| 12 | finance | Finanzas |
| 19 | digemid | Farmacia |

### Activar Módulo de Farmacia

Para que "Farmacia" aparezca como menú principal:

```sql
-- En la BD del tenant
UPDATE tenancy_[NOMBRE_CLIENTE].configurations 
SET is_pharmacy = 1 
WHERE id = 1;
```

---

## 🏢 Configuración SUNAT

### Arquitectura del Sistema

FacturadorPro5 **NO usa servicios de terceros** (como Nubefact). Se conecta **directamente a SUNAT**:

- ✅ Firma XML con tu certificado digital
- ✅ Envío directo a web services de SUNAT
- ✅ Procesa CDR (Constancia de Recepción)

### Endpoints SUNAT

| Tipo | Producción | Beta/Pruebas |
|------|-----------|--------------|
| **Facturación** | `e-factura.sunat.gob.pe` | `e-beta.sunat.gob.pe` |
| **Guías** | `e-guiaremision.sunat.gob.pe` | `e-beta.sunat.gob.pe` |
| **Retenciones** | `e-factura.sunat.gob.pe` | `e-beta.sunat.gob.pe` |

### Requisitos Previos

1. **Usuario SOL** (SUNAT Operaciones en Línea)
2. **Clave SOL**
3. **Certificado Digital** (archivo `.pfx`)
4. **Contraseña del certificado**

### Configuración en el Sistema

**Accede a:** Configuración → Empresa

**Configura:**

1. **Datos de la empresa:**
   - RUC
   - Razón Social
   - Nombre Comercial
   - Dirección Fiscal

2. **Credenciales SUNAT:**
   - Usuario SOL
   - Clave SOL
   - Subir certificado `.pfx`
   - Contraseña del certificado

3. **Entorno:**
   - ☑️ Producción (para emitir comprobantes reales)
   - ☐ Beta (para pruebas)

---

## 👥 Creación de Clientes/Tenants

### ¿Qué es un Tenant?

El sistema es **multi-tenant**: cada cliente tiene su propia base de datos independiente.

### Paso 1: Acceder al Admin

1. **Ve a:** `http://facturadorpro5.test`
2. **Login:**
   - Usuario: `admin@gmail.com`
   - Contraseña: `123456`

### Paso 2: Crear Cliente

1. **Menú** → Clientes → Nuevo
2. **Completa datos:**
   - Número (RUC)
   - Nombre/Razón Social
   - Email
   - **Subdominio** (ej: `empresa1`)
   - Plan

> ⚠️ **REGLAS DEL SUBDOMINIO:**
> - Solo letras minúsculas y números
> - **NO** usar espacios
> - **NO** usar la letra **Ñ**
> - **NO** usar caracteres especiales (-, _, @, etc.)
> - Ejemplo válido: `empresa1`, `cliente2`
> - Ejemplo inválido: `empresa-1`, `cliente_2`, `año2024`

3. **Guardar**

### Paso 3: Configurar DNS Local

**Edita el archivo hosts:**

```powershell
notepad C:\Windows\System32\drivers\etc\hosts
```

**Agrega:**

```
127.0.0.1 empresa1.facturadorpro5.test
```

**Guarda** (requiere permisos de administrador)

### Paso 4: Acceder al Tenant

**URL:** `http://empresa1.facturadorpro5.test`

**Credenciales por defecto:**
- Usuario: `[email_configurado]`
- Contraseña: `123456`

---

## 🔧 Solución de Problemas

### MySQL no inicia

**Síntoma:** Laragon se queda en "Initializing..."

**Solución:**

```powershell
# Verificar puerto 3306
netstat -ano | findstr :3306

# Si hay conflicto, detener proceso o cambiar puerto en my.ini
```

### Error de Foreign Key

**Síntoma:** 
```
SQLSTATE[HY000]: General error: 6125 Failed to add the foreign key constraint
```

**Causa:** Estás usando MySQL 8.0+

**Solución:** Cambiar a MySQL 5.7 (ver sección correspondiente)

### Base de datos "tenancy" no existe

**Solución:**

```powershell
D:\laragon\bin\mysql\mysql-5.7.44-winx64\bin\mysql.exe -u root -e "CREATE DATABASE tenancy;"
```

### Mix Manifest Error

**Síntoma:**
```
The Mix manifest does not exist
```

**Solución:**

```powershell
npm install
npm run dev
```

### Imágenes no cargan / Error con Logo
**Síntoma:** Al generar PDF sale error `mime_content_type` o las imágenes se ven rotas.
**Solución:** El enlace simbólico de almacenamiento está roto. Ejecuta:
```powershell
php artisan storage:link
```
Si persiste, borra la carpeta `public/storage` manualment y ejecuta el comando de nuevo.

### Tenant no carga (404)

**Verifica:**

1. ✅ Hostname agregado en archivo `hosts`
2. ✅ Cliente creado en admin
3. ✅ Apache reiniciado

---

## 📞 Soporte

### Documentación Oficial

- **README principal:** `README.md`
- **Manuales:** Ver enlaces en README principal
- **API Docs:** Disponible en Google Drive (ver README)

### Recursos Adicionales

- **API Peru Dev:** [https://apiperu.dev](https://apiperu.dev)
- **SUNAT:** [https://www.sunat.gob.pe](https://www.sunat.gob.pe)
- **FacturaloPeru:** [https://facturaloperu.com](https://facturaloperu.com)

---

## ✅ Checklist de Instalación

- [ ] Laragon instalado
- [ ] MySQL 5.7.44 descargado e instalado
- [ ] MySQL 5.7 inicializado y funcionando
- [ ] Proyecto copiado a `D:\laragon\www\facturadorpro5`
- [ ] Archivo `.env` configurado
- [ ] Dependencias instaladas (`composer install`)
- [ ] Base de datos `tenancy` creada
- [ ] Migraciones ejecutadas (`php artisan migrate --database=system`)
- [ ] Seeders ejecutados (`php artisan db:seed --database=system`)
- [ ] Token API Peru Dev configurado
- [ ] Primer cliente/tenant creado
- [ ] Hostname agregado al archivo `hosts`
- [ ] Módulos activados
- [ ] Certificado SUNAT configurado (si aplica)

---

## 📝 Notas Importantes

> **MySQL 5.7 es OBLIGATORIO:** El sistema no funcionará correctamente con MySQL 8.0+ debido a incompatibilidades en las migraciones y sintaxis SQL.

> **Multi-Tenancy:** Cada cliente requiere su propia entrada en el archivo `hosts` de Windows.

> **Certificado Digital:** Necesario solo para emitir comprobantes electrónicos reales. Para desarrollo/pruebas se puede usar el entorno Beta de SUNAT.

> **API Peru Dev:** El token es necesario para consultas de RUC/DNI/RENIEC. Obtén uno gratuito en [apiperu.dev](https://apiperu.dev).

---

**Documentación creada:** 2026-01-06
