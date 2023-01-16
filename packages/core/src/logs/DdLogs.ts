/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2016-Present Datadog, Inc.
 */

import { NativeModules } from 'react-native';

import { InternalLog } from '../InternalLog';
import { SdkVerbosity } from '../SdkVerbosity';
import type { DdNativeLogsType } from '../nativeModulesTypes';
import { AttributesSingleton } from '../sdk/AttributesSingleton/AttributesSingleton';
import { UserInfoSingleton } from '../sdk/UserInfoSingleton/UserInfoSingleton';

import { applyLogEventMapper, formatLogEvent } from './eventMapper';
import type { DdLogsType, LogEventMapper, LogStatus, NativeLog } from './types';

const generateEmptyPromise = () => new Promise<void>(resolve => resolve());

class DdLogsWrapper implements DdLogsType {
    private nativeLogs: DdNativeLogsType = NativeModules.DdLogs;
    private logEventMapper: LogEventMapper | null = null;

    debug(message: string, context: object = {}): Promise<void> {
        return this.log(message, context, 'debug');
    }

    info(message: string, context: object = {}): Promise<void> {
        return this.log(message, context, 'info');
    }

    warn(message: string, context: object = {}): Promise<void> {
        return this.log(message, context, 'warn');
    }

    error(message: string, context: object = {}): Promise<void> {
        return this.log(message, context, 'error');
    }

    private log = (
        message: string,
        context: object,
        status: keyof DdNativeLogsType
    ): Promise<void> => {
        InternalLog.log(
            `Tracking ${status} log “${message}”`,
            SdkVerbosity.DEBUG
        );
        const event = this.applyLogEventMapper(message, context, status);
        if (!event) {
            return generateEmptyPromise();
        }
        return this.nativeLogs[status](event.message, event.context);
    };

    registerLogEventMapper(logEventMapper: LogEventMapper) {
        this.logEventMapper = logEventMapper;
    }

    unregisterLogEventMapper() {
        this.logEventMapper = null;
    }

    private applyLogEventMapper = (
        message: string,
        context: object,
        logStatus: LogStatus
    ): NativeLog | null => {
        if (!this.logEventMapper) {
            return { message, context };
        }

        const userInfo = UserInfoSingleton.getInstance().getUserInfo();
        const attributes = AttributesSingleton.getInstance().getAttributes();
        const initialLogEvent = formatLogEvent(
            { message, context },
            { logStatus, userInfo, attributes }
        );

        return applyLogEventMapper(this.logEventMapper, initialLogEvent);
    };
}

export const DdLogs = new DdLogsWrapper();
