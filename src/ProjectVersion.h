/**
 *  \file       ProjectVersion.h
 *  \brief      Defines the Project version
 */

/* -------------------------- Development history -------------------------- */
/* -------------------------------- Authors -------------------------------- */
/*
 *  LeFr  Leandro Francucci  lf@vortexmakes.com
 */

/* --------------------------------- Notes --------------------------------- */
/* --------------------------------- Module -------------------------------- */
#ifndef __PROJECTVERSION_H__
#define __PROJECTVERSION_H__

/* ----------------------------- Include files ----------------------------- */
/* ---------------------- External C language linkage ---------------------- */
#ifdef __cplusplus
extern "C" {
#endif

/* --------------------------------- Macros -------------------------------- */
/* -------------------------------- Constants ------------------------------ */
/**
 *  \brief
 *	This macro expands to the binary representation of the Project version,
 *  which follows the semantic and format provided by https://semver.org/
 *
 *	The version number is composed by 0xABCCDD, where:
 *	- A (1-digit) denoted the major version
 *  - B (1-digit) denoted the minor version
 *	- C (2-digits) denoted the patch version
 *  - D (2-digits) denoted the beta version.
 *
 *  As a general rule, given a version number major.minor.patch, increment 
 *  the:
 *  1. major version when you make incompatible API changes,
 *  2. minor version when you add functionality in a backwards compatible 
 *     manner, and
 *  3. patch version when you make backwards compatible bug fixes.
 *  
 *  Additional labels for pre-release are available as extensions to the 
 *  major.minor.patch format.
 *
 *  For example, the code for version 2.2.04 is 0x220400 and the code 
 *  for version 2.2.04-beta.2 is 0x220402
 */
#define PROJECT_VERSION         0x090007

/**
 *  \brief
 *  This macro indicates the release date as string in DDMMYY format.
 */
#define PROJECT_RELEASE_DATE    "180920"

/* ------------------------------- Data types ------------------------------ */
/* -------------------------- External variables --------------------------- */
/**
 *  \brief
 *  String indicating the Project version.
 */
extern const char projectVersion[];

/* -------------------------- Function prototypes -------------------------- */
/* -------------------- External C language linkage end -------------------- */
#ifdef __cplusplus
}
#endif

/* ------------------------------ Module end ------------------------------- */
#endif

/* ------------------------------ End of file ------------------------------ */
