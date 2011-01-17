/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project on Qt Labs.
**
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions contained
** in the Technology Preview License Agreement accompanying this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/

#include <QtTest/QtTest>
#include "apicheckbase.h"

class ApiCheckButton : public ApiCheckBase
{
    Q_OBJECT

private slots:
    void initTestCase();
    void checked();
    void checkable();
    void pressed();
    void text();
    void iconSource();
    void clicked();
};

void ApiCheckButton::initTestCase()
{
    init("ApiCheckButton.qml");
}

void ApiCheckButton::checked()
{
    validateProperty("checked", QVariant::Bool);
}

void ApiCheckButton::checkable()
{
    validateProperty("checkable", QVariant::Bool);
}

void ApiCheckButton::pressed()
{
    validateProperty("pressed", QVariant::Bool);
}

void ApiCheckButton::text()
{
    validateProperty("text", QVariant::String);
}

void ApiCheckButton::iconSource()
{
    validateProperty("iconSource", QVariant::Url);
}

void ApiCheckButton::clicked()
{
    validateSignal("clicked()");
}

QTEST_MAIN(ApiCheckButton);

#include "apicheck_button.moc"
