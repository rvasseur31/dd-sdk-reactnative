/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2016-Present Datadog, Inc.
 */

import type { Spec as NativeDdInternalTesting } from './specs/NativeDdInternalTesting';

/**
 * In this file, native modules types extend the specs for TurboModules.
 * As we cannot use enums or classes in the specs, we override methods using them here.
 */

/**
 * The entry point to use the native internal testing module.
 */
export interface NativeInternalTestingType extends NativeDdInternalTesting {
    /**
     * Enable internal testing.
     */
    enable(): Promise<void>;
}
